package main

import (
	"bufio"
	"log"
	"os"
	"sort"
	"strconv"
)

func main() {
	calories := make([]int, 1)
	currentIndex := 0

	file, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		if len(scanner.Text()) == 0 {
			currentIndex += 1
			calories = append(calories, 0)
		} else {
			currentCalories, err := strconv.Atoi(scanner.Text())
			if err != nil {
				log.Fatal(err)
			}
			calories[currentIndex] += currentCalories
		}
	}
	sort.Ints(calories)
	log.Print(calories[len(calories)-1] + calories[len(calories)-2] + calories[len(calories)-3])
}
