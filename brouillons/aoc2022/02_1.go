package main

import (
	"bufio"
	"log"
	"os"
	"strings"
)

func main() {
	currentScore := 0

	file, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		values := strings.Split(scanner.Text(), " ")
		you := values[1]
		opponent := values[0]
		switch opponent {
		case "A":
			switch you {
			case "X":
				currentScore += 3
			case "Y":
				currentScore += 6
			case "Z":
			default:
				log.Fatal("Unexpected value [", you, "]")
			}
		case "B":
			switch you {
			case "X":
			case "Y":
				currentScore += 3
			case "Z":
				currentScore += 6
			default:
				log.Fatal("Unexpected value [", you, "]")
			}
		case "C":
			switch you {
			case "X":
				currentScore += 6
			case "Y":
			case "Z":
				currentScore += 3
			default:
				log.Fatal("Unexpected value [", you, "]")
			}

		default:
			log.Fatal("Unexpected value [", opponent, "]")
		}
		switch you {
		case "X":
			currentScore += 1
		case "Y":
			currentScore += 2
		case "Z":
			currentScore += 3
		default:
			log.Fatal("Unexpected value [", you, "]")
		}

	}
	log.Print(currentScore)
}
