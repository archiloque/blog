package main

import (
	"bufio"
	"log"
	"os"
	"strconv"
)

func main() {
	currentCalories := 0
	maxCalories := 0

	file, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		if len(scanner.Text()) == 0 {
			if currentCalories > maxCalories {
				maxCalories = currentCalories
			}
			currentCalories = 0
		} else {
			value, err := strconv.Atoi(scanner.Text())
			if err != nil {
				log.Fatal(err)
			}
			currentCalories += value
		}
	}
	log.Print(maxCalories)
}
