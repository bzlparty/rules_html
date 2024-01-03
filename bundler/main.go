package main

import (
	"flag"
	"fmt"
	"os"
	"strings"

	"golang.org/x/net/html"
)

var (
	entryPoint = flag.String("entry_point", "", "Entry Point")
	output     = flag.String("out", "", "Output File")
)

func main() {
	flag.Parse()
	content, _ := os.ReadFile(*entryPoint)
	bundled := inlineFiles(content)

	os.WriteFile(*output, bundled, 0644)
}

func inlineFiles(document []byte) (result []byte) {
	tokenizer := html.NewTokenizer(strings.NewReader(string(document)))
Token:
	for {
		tt := tokenizer.Next()

		if tt == html.ErrorToken {
			break Token
		}

		name, _ := tokenizer.TagName()
		ttype := tokenizer.Token().Type
		if string(name) == "script" && ttype == html.StartTagToken {
			for {
				key, val, m := tokenizer.TagAttr()
				if string(key) == "src" {
					content, err := os.ReadFile(string(val))
					if err != nil {
						fmt.Println("File not found")
						continue Token
					}
					result = append(result, []byte("<script>\n")...)
					result = append(result, content...)
					result = append(result, []byte("\n")...)
				}
				if m == false {
					continue Token
				}
			}
		}
		if string(name) == "link" {
			for {
				key, val, m := tokenizer.TagAttr()
				if string(key) == "href" {
					content, err := os.ReadFile(string(val))
					if err != nil {
						fmt.Println("File not found")
						continue Token
					}
					result = append(result, []byte("<style>\n")...)
					result = append(result, content...)
					result = append(result, []byte("</style>\n")...)
				}
				if m == false {
					continue Token
				}
			}
		}
		raw := tokenizer.Raw()
		result = append(result, raw...)
	}
	return
}
