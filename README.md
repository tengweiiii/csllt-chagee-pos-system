# CHAGEE Point of Sale (POS) System

## Overview

The CHAGEE Point of Sale (POS) System is a menu-driven application developed in x86 NASM Assembly Language for Linux. The system simulates a beverage ordering process at CHAGEE by allowing customers to select drinks, customize their orders, manage their cart, and complete payment transactions.

This project was developed as part of the **CT073-3-2 Computer System Low Level Techniques (CSLLT)** module and demonstrates the use of arithmetic operations, loops, conditional jumps, arrays, procedures, and memory management in assembly language.

---

## Features

### Drink Ordering

Customers can choose from five CHAGEE beverages:

1. BO.YA Jasmine Green Milk Tea
2. White Peach Oolong Milk Tea
3. Da Hong Pao Milk Tea
4. Tie Guan Yin Milk Tea
5. Hojicha Genmai Milk Tea

### Drink Size Selection

Each beverage is available in:

* Regular Size
* Large Size

Different sizes have different prices.

### Sugar Level Customization

Customers may choose:

* Normal Sweet
* Less Sweet
* Slightly Sweet
* No Additional Sugar

### Ice Level Customization

Customers may choose:

* Normal Ice
* Less Ice
* No Ice
* Hot

### Quantity Selection

Users can specify the quantity for each customized drink.

### Smart Cart Management

The system automatically merges identical orders.

For example:

* BO.YA + Regular + Normal Sweet + Normal Ice + Qty 1
* BO.YA + Regular + Normal Sweet + Normal Ice + Qty 1

will be combined into:

* BO.YA + Regular + Normal Sweet + Normal Ice + Qty 2

instead of creating duplicate records.

### Shopping Cart Display

The cart displays:

* Drink Name
* Size
* Sugar Level
* Ice Level
* Quantity
* Current Subtotal

Users may:

* Continue Ordering
* Proceed to Checkout

### Receipt Generation

The receipt displays:

* Drink Name
* Size
* Sugar Level
* Ice Level
* Quantity
* Line Total
* Subtotal
* SST (6%)
* Grand Total

### Payment Processing

The system accepts customer payment and automatically calculates:

* Payment Amount
* Change Returned

---

## System Workflow

1. Display menu
2. Select drink
3. Select size
4. Select sugar level
5. Select ice level
6. Enter quantity
7. Add item to cart
8. Display cart summary
9. Continue ordering or checkout
10. Generate receipt
11. Calculate SST (6%)
12. Accept payment
13. Calculate change
14. End transaction

---

## Data Structures

The system uses arrays to store order information.

| Array       | Purpose                 |
| ----------- | ----------------------- |
| order_items | Stores drink selections |
| order_sizes | Stores selected size    |
| order_sugar | Stores sugar levels     |
| order_ice   | Stores ice levels       |
| order_qtys  | Stores quantities       |

Maximum order capacity:

* 20 order records

---

## Price List

| Drink                        |  Regular |    Large |
| ---------------------------- | -------: | -------: |
| BO.YA Jasmine Green Milk Tea | RM 11.90 | RM 13.90 |
| White Peach Oolong Milk Tea  | RM 11.90 | RM 13.90 |
| Da Hong Pao Milk Tea         | RM 12.90 | RM 14.90 |
| Tie Guan Yin Milk Tea        | RM 14.90 | RM 16.90 |
| Hojicha Genmai Milk Tea      | RM 13.90 | RM 15.90 |

---

## Technical Concepts Demonstrated

This project demonstrates the following assembly language concepts:

* Arithmetic Operations

  * Addition
  * Multiplication
  * Division

* Conditional Jumps

  * JE
  * JNE
  * JL
  * JG

* Unconditional Jumps

  * JMP

* Loops

  * Order Processing Loop
  * Cart Display Loop
  * Receipt Printing Loop

* Arrays and Indexed Memory Access

* Procedures and Modular Programming

* String Processing

* User Input Handling

* Numeric Conversion

---

## Compile and Run

### Assemble

```bash
nasm -f elf32 Chagee.asm -o Chagee.o
```

### Link

```bash
ld -m elf_i386 Chagee.o -o Chagee
```

### Run

```bash
./Chagee
```

---

## Sample Receipt

```text
=================================================================
                             RECEIPT
=================================================================

BO.YA Jasmine Green Milk Tea
Size   : Regular
Sugar  : Normal Sweet
Ice    : Normal Ice
Qty    : 2
Amount : RM 23.80

-----------------------------------------------------------------

Subtotal : RM 23.80
SST 6%   : RM 1.42
Total    : RM 25.22

Payment  : RM 30.00
Change   : RM 4.78
```

---

## Learning Outcomes

This project demonstrates the practical application of assembly language in developing a real-world business application. Through this project, concepts such as memory management, arithmetic computation, loops, conditional branching, array manipulation, and modular programming are applied to create a functional Point of Sale system.

---

## Author

Teng Wei

Asia Pacific University of Technology & Innovation (APU)

Bachelor of Computer Science (Data Analytics)

CT073-3-2 Computer System Low Level Techniques
