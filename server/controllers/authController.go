package controllers

import (
	"fmt"

	"github.com/gofiber/fiber/v2"
)

func Register(c *fiber.Ctx) error {
	var data map[string]string

	if err := c.BodyParser(&data); err != nil {
		fmt.Printf("Error parsing body in the register controller: %v", err)
		return err
	}

}
