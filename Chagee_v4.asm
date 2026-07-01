; ==================================================================================================
; CHAGEE POS SYSTEM
; This program runs in 32-bit Linux and uses NASM assembly syntax
; The system allows a user to select drinks, customize them, view a cart then checkout and pay
; All prices are stored in cents so we don't need to deal with decimal math
; ==================================================================================================

; --------------------------------------------------------------------------------------------------
; section .data
; This section holds all the fixed text the program will print to the screen and the price lists
; Nothing here changes size when the program runs
; --------------------------------------------------------------------------------------------------
section .data    
       ; the welcome banner
       header db "=================================================================",10          ; 10 is the newline character
              db "                        WELCOME TO CHAGEE                        ",10
              db "=================================================================",10,0        ; 0 is a null terminator
       
       ; the title shown above the drink menu each time it is displayed
       menu_title db 10,"------------------------------ MENU -----------------------------",10,0
       
       ; each line of the menu is its own string
       item1 db "1. BO•YA Jasmine Green Milk Tea     RM 11.90 (R) | RM 13.90 (L)",10,0
       item2 db "2. White Peach Oolong Milk Tea      RM 11.90 (R) | RM 13.90 (L)",10,0
       item3 db "3. Da Hong Pao Milk Tea             RM 12.90 (R) | RM 14.90 (L)",10,0
       item4 db "4. Tie Guan Yin Milk Tea            RM 14.90 (R) | RM 16.90 (L)",10,0
       item5 db "5. Hojicha Genmai Milk Tea          RM 13.90 (R) | RM 15.90 (L)",10,0
       item0 db "0. Checkout                                                    ",10,0           ; item0 allows user to skip ordering and proceeds to checkout
       ask_item db 10,"Please select a drink: ", 0                                               ; text that prompt user to select a drink             
       
       ; list of drinks size after a drink is selected
       size_menu db 10,"Size: ", 10
                 db "1. Regular", 10
                 db "2. Large", 10, 0
       ask_size db "Please select a size: ", 0                                                   ; text that prompt user to select a drinks size
       
       ; list of sugar level choices
       sugar_menu db 10,"Sugar Level", 10
                  db "1. Normal Sweet", 10
                  db "2. Less Sweet", 10
                  db "3. Slightly Sweet", 10
                  db "4. No Additional Sugar", 10, 0
       ask_sugar db "Please select a sugar level: ", 0                                           ; text that prompt users to select a sugar level
       
       ; list of ice level choices
       ice_menu db 10,"Ice Level", 10
                db "1. Normal Ice", 10
                db "2. Less Ice", 10
                db "3. No Ice", 10
                db "4. Hot", 10, 0
       
       ask_ice db "Please select an ice level: ", 0                                              ; text that prompt users to select an ice level 
       ask_qty db "Please enter the quantity (1-9): ", 0                                         ; text that prompt users asking how many cups of this exact drink to add
       
       added_msg db ">>> Item Added Successfully!", 10, 0                                        ; message shown after an item is successfully added to the cart
       invalid_msg db "Invalid input. Please try again.", 10, 0                                  ; message shown when the user types something out of range
       
       ; banner shown above the cart summary
       cart_hdr db 10
                db "=================================================================",10
                db "                               CART                              ",10
                db "=================================================================",10,0
       
       ; label shown before the running subtotal in the cart view
       cart_subtotal db "Current Subtotal : RM ", 0
       
       ; option shown after viewing the cart
       continue_menu db 10
                     db "1. Continue Ordering", 10
                     db "2. Checkout", 10, 0
       ask_continue db "Choice: ", 0                                                             ; text that prompt users to continue ordering or to checkout
       
       ; banner shown above the final receipt during checkout
       receipt_hdr db 10
                   db "=================================================================",10
                   db "                             RECEIPT                             ",10
                   db "=================================================================",10,0
       
       ; a line used to separate items visually
       divider db "-----------------------------------------------------------------",10,0
       
       ; labels printed before each detail of an order line
       ; used in cart view and receipt
       size_label db "Size   : ", 0
       sugar_label db "Sugar  : ", 0
       ice_label db "Ice    : ", 0
       qty_label db "Qty    : ", 0
       amount_label db "Amount : RM ", 0
       
       ; labels for money summary section of the receipt
       sub_label db "Subtotal : RM ", 0
       tax_label db "SST 6%   : RM ", 0
       total_label db "Total    : RM ", 0
       
       ; labels for payment and change 
       payment_label db "Payment  : RM ", 0
       change_label db "Change   : RM ", 0
       
       ask_payment db 10, "Enter Payment Amount (RM): ", 0                                         ; text that prompt users asking how much cash they are paying with
       newline db 10, 0                                                                            ; a string used to move to a new line without printing any text
       dot_str db ".", 0                                                                           ; a dot character used to print money as RM12.90
       zero_pad db "0", 0                                                                          ; 0 character used to pad numbers under 10 cents e.i 5 cents prints as "05" instead of "5"

       ; goodbye message after a payment is complete
       thankyou db 10
                db "=================================================================",10
                db "                 Thank You For Visiting CHAGEE!                  ",10
                db "=================================================================",10,0
       
       ; drink names without prices when printing the cart and receipt
       iname1 db "BO.YA Jasmine Green Milk Tea",0
       iname2 db "White Peach Oolong Milk Tea",0
       iname3 db "Da Hong Pao Milk Tea",0
       iname4 db "Tie Guan Yin Milk Tea",0
       iname5 db "Hojicha Genmai Milk Tea",0

       ; a lookup table of addresses to each drink name
       ; dd means each entry is a 4-byte value
       ; serves as a memory address that allow us to find a name by index
       iname_table dd iname1,iname2,iname3,iname4,iname5

       ; text used to print whether the drinks size is regular or large
       regular_txt db "Regular",0
       large_txt db "Large",0

       ; same lookup table idea as iname_table, but for sugar level text
       sugar1 db "Normal Sweet",0
       sugar2 db "Less Sweet",0
       sugar3 db "Slightly Sweet",0
       sugar4 db "No Additional Sugar",0
       sugar_table dd sugar1,sugar2,sugar3,sugar4
       
       ; same lookup table idea as iname_table, but for ice level text
       ice1 db "Normal Ice",0
       ice2 db "Less Ice",0
       ice3 db "No Ice",0
       ice4 db "Hot",0
       ice_table dd ice1,ice2,ice3,ice4
       
       ; price lists in cents
       ; in the same order as the drink menu
       regular_prices dd 1190,1190,1290,1490,1390
       large_prices   dd 1390,1390,1490,1690,1590

; --------------------------------------------------------------------------------------------------
; section .bss
; This section reserves empty memory space for values that will change while the program runs
; Nothing is stored here, it is just reserved space
; --------------------------------------------------------------------------------------------------
section .bss
       input_buf resb 32                                                                          ; reserve 32 bytes to hold user input
       num_buf resb 16                                                                            ; reserve 16 bytes used to convert a number into text to be printed                                                                          
       
       subtotal resd 1                                                                            ; reserves space for the running total of all items in the cart in cents
       tax resd 1                                                                                 ; reserves space for the calculated 6% tax amount in cents
       total resd 1                                                                               ; reserves space for subtotal + tax in cents
       
       payment resd 1                                                                             ; reserves space for how much cash the customer pays in cents
       change resd 1                                                                              ; reserves space for how much change is owed back in cents
       
       order_count resd 1                                                                         ; reserves space for how many different order lines are in the cart
       order_items resd 20                                                                        ; reserves space for up to 20 order lines, storing which drink was picked for each line
       order_sizes resd 20                                                                        ; reserves space for the size (0=Regular, 1=Large) of each of the 20 possible order lines
       order_sugar resd 20                                                                        ; reserves space for the sugar level (0-3) of each order line
       order_ice resd 20                                                                          ; reserves space for the ice level (0-3) of each order line
       order_qtys resd 20                                                                         ; reserves space for the quantity ordered of each order line

; --------------------------------------------------------------------------------------------------
; section .text
; This section marks _starts as the entry point. This is where the program begins running.
; --------------------------------------------------------------------------------------------------
section .text
global _start

_start:
       mov dword [subtotal], 0                                                                    ; set subtotal to 0 cent before any items are added
       mov dword [order_count], 0                                                                 ; set number of order lines to 0 since the cart is empty
       
       mov eax, header                                                                            ; load the address of the welcome banner text into eax
       call print_str                                                                             ; call print_str function to print the banner to the screen

order_loop:
       mov eax, menu_title                                                                        ; load the address of the menu title text into eax
       call print_str                                                                             ; call print_str function to print the banner to the screen

       mov eax, item1                                                                             ; load the address of the first drink text into eax
       call print_str                                                                             ; call print_str function to print the first drinks to the screen

       mov eax, item2                                                                             ; load the address of the second drink text into eax
       call print_str                                                                             ; call print_str function to print the second drinks to the screen

       mov eax, item3                                                                             ; load the address of the third drink text into eax
       call print_str                                                                             ; call print_str function to print the third drinks to the screen

       mov eax, item4                                                                             ; load the address of the fourth drink text into eax
       call print_str                                                                             ; call print_str function to print the fourth drinks to the screen

       mov eax, item5                                                                             ; load the address of the fifth drink text into eax
       call print_str                                                                             ; call print_str function to print the fifth drinks to the screen

       mov eax, item0                                                                             ; load the address of the checkout option text into eax
       call print_str                                                                             ; call print_str function to print the checkout option to the screen
       
       mov eax, ask_item                                                                          ; print the prompt asking users which drink to pick                                    
       call print_str
       
       mov eax, 3                                                                                 ; sys_read system call 
       mov ebx, 0                                                                                 ; file descriptor 0 (stdin)
       mov ecx, input_buf                                                                         ; address to store the user input
       mov edx, 32                                                                                ; number of bytes to read (32 bytes)
       int 0x80                                                                                   ; invoke the system call
       
       movzx eax,byte [input_buf]                                                                 ; load only the first character the user typed into eax
       
       cmp eax, '0'                                                                               ; if user typed '0' 
       je checkout                                                                                ; skip to checkout (je - jump if equal)
       
       cmp eax, '1'                                                                               ; if the character is less than '1' 
       jl bad_item                                                                                ; print invalid input message (jl - jump if less)
       
       cmp eax, '5'                                                                               ; if the character is more than '1'
       jg bad_item                                                                                ; print invalid input message (jg - jump if greater)
       
       sub eax, '1'                                                                               ; convert the character (1-5) into plain number (0-4)
                                                                                                  ; 0-4 matches the index position in tables
       
       mov esi, eax                                                                               ; store the chosen drink index in esi so it is not overwritten while ask for size, sugar and ice

size_selection:
       mov eax, size_menu                                                                         ; load the address of the drinks size text into eax
       call print_str                                                                             ; call print_str function to print the drinks size menu to the screen

       mov eax, ask_size                                                                          ; print the prompt asking users which drinks size to pick 
       call print_str
       
       mov eax, 3                                                                                 ; sys_read system call 
       mov ebx, 0                                                                                 ; file descriptor 0 (stdin)
       mov ecx, input_buf                                                                         ; address to store the user input
       mov edx, 32                                                                                ; number of bytes to read (32 bytes)
       int 0x80                                                                                   ; invoke the system call
       
       movzx eax,byte [input_buf]                                                                 ; load only the first character the user typed into eax
                                                                                                  ; movzx - move with zero extend
       
       cmp eax, '1'                                                                               ; if the character is less than '1' 
       jl bad_item                                                                                ; print invalid input message (jl - jump if less)

       cmp eax, '5'                                                                               ; if the character is more than '1'
       jg bad_item                                                                                ; print invalid input message (jg - jump if greater)
       
       sub eax, '1'                                                                               ; convert the character (1/2) into plain number (0/1)
                                                                                                  ; 0-1 matches the index position in iname_tables
       
       mov edi, eax                                                                               ; save the drinks size choice in edi for future use

sugar_selection:
       mov eax, sugar_menu                                                                         ; load the address of the sugar level text into eax
       call print_str                                                                             ; call print_str function to print the sugar level menu to the screen

       mov eax, ask_sugar                                                                          ; print the prompt asking users which sugar level to pick 
       call print_str
       
       mov eax, 3                                                                                 ; sys_read system call 
       mov ebx, 0                                                                                 ; file descriptor 0 (stdin)
       mov ecx, input_buf                                                                         ; address to store the user input
       mov edx, 32                                                                                ; number of bytes to read (32 bytes)
       int 0x80                                                                                   ; invoke the system call
       
       movzx eax,byte [input_buf]                                                                 ; load only the first character the user typed into eax
                                                                                                  ; movzx - move with zero extend
       
       cmp eax, '1'                                                                               ; if the character is less than '1' 
       jl bad_item                                                                                ; print invalid input message (jl - jump if less)

       cmp eax, '5'                                                                               ; if the character is more than '5'
       jg bad_item                                                                                ; print invalid input message (jg - jump if greater)
       
       sub eax, '1'                                                                               ; convert the character (1/2) into plain number (0/1)
                                                                                                  ; 0-1 matches the index position in sugar_tables
       
       mov ebp, eax                                                                               ; save the drinks size choice in edi for future use

ice_selection:
       mov eax, ice_menu                                                                          ; load the address of the ice level text into eax
       call print_str                                                                             ; call print_str function to print the ice level menu to the screen

       mov eax, ask_ice                                                                           ; print the prompt asking users which ice level to pick 
       call print_str
       
       mov eax, 3                                                                                 ; sys_read system call 
       mov ebx, 0                                                                                 ; file descriptor 0 (stdin)
       mov ecx, input_buf                                                                         ; address to store the user input
       mov edx, 32                                                                                ; number of bytes to read (32 bytes)
       int 0x80                                                                                   ; invoke the system call
       
       movzx eax,byte [input_buf]                                                                 ; load only the first character the user typed into eax
                                                                                                  ; movzx - move with zero extend
       
       cmp eax, '1'                                                                               ; if the character is less than '1' 
       jl bad_item                                                                                ; print invalid input message (jl - jump if less)

       cmp eax, '4'                                                                               ; if the character is more than '4'
       jg bad_item                                                                                ; print invalid input message (jg - jump if greater)
       
       sub eax, '1'                                                                               ; convert the character (1-4) into plain number (0-3)
                                                                                                  ; 0-1 matches the index position in ice_table
       
       push eax                                                                                   ; push the ice choice onto the stack to save it
                                                                                                  ; because we are running out of free registers (esi, edi, ebp are holding drink, size and sugar)

quantity_selection:
       mov eax, ask_qty                                                                           ; print the prompt asking users how many quantity to pick 
       call print_str
       
       mov eax, 3                                                                                 ; sys_read system call 
       mov ebx, 0                                                                                 ; file descriptor 0 (stdin)
       mov ecx, input_buf                                                                         ; address to store the user input
       mov edx, 32                                                                                ; number of bytes to read (32 bytes)
       int 0x80                                                                                   ; invoke the system call
       
       movzx eax,byte [input_buf]                                                                 ; load only the first character the user typed into eax
                                                                                                  ; movzx - move with zero extend
       
       sub eax, '0'                                                                               ; convert the typed character into plain number 
       
       cmp eax, '1'                                                                               ; if the character is less than '1' 
       jl bad_item                                                                                ; print invalid input message (jl - jump if less)

       cmp eax, '9'                                                                               ; if the character is more than '9'
       jg bad_item                                                                                ; print invalid input message (jg - jump if greater)
       
       mov edx, eax                                                                               ; save the quantity in edx
       
       pop ecx                                                                                    ; retrieve the ice choice we push earlier and put it in ecx
       
       mov ebx, 0                                                                                 ; ebx will be used as loop counter starting at 0

find_existing:  
       cmp ebx,[order_count]
       jge add_new_item
       
       mov eax,[order_items + ebx*4]
       
       cmp eax,esi
       jne next_record
       
       mov eax,[order_sizes + ebx*4]
       
       cmp eax,edi
       jne next_record
       
       mov eax,[order_sugar + ebx*4]
       
       cmp eax,ebp
       jne next_record
       
       mov eax,[order_ice + ebx*4]
       
       cmp eax,ecx
       jne next_record
       
       mov eax,[order_qtys + ebx*4]
       
       add eax,edx
       
       mov [order_qtys + ebx*4],eax
       
       cmp edi,0
       je merge_regular_price
       
       mov eax,[large_prices + esi*4]
       jmp merge_price_done
       
       merge_regular_price:
       
       mov eax,[regular_prices + esi*4]
       
       merge_price_done:
       
       imul eax,edx
       
       add [subtotal],eax
       
       mov eax,added_msg
       call print_str
       
       jmp show_cart

next_record:
       inc ebx
       jmp find_existing

add_new_item:
       mov ebx,[order_count]
       
       cmp ebx,20
       jge order_loop
       
       mov [order_items + ebx*4],esi
       mov [order_sizes + ebx*4],edi
       mov [order_sugar + ebx*4],ebp
       mov [order_ice + ebx*4],ecx
       mov [order_qtys + ebx*4],edx
       
       inc dword [order_count]
       
       cmp edi,0
       je new_regular_price
       
       mov eax,[large_prices + esi*4]
       jmp new_price_done
    
new_regular_price:
       mov eax,[regular_prices + esi*4]
       
       new_price_done:
       
       imul eax,edx
       
       add [subtotal],eax
       
       mov eax,added_msg
       call print_str
       
       jmp show_cart

bad_item:
       mov eax,invalid_msg
       call print_str
       jmp order_loop

bad_qty:
       mov eax,invalid_msg
       call print_str
       jmp order_loop

show_cart:
       mov eax,cart_hdr
       call print_str
       
       mov esi,0

cart_loop:
       cmp esi,[order_count]
       jge cart_done
       
       mov ebx,[order_items + esi*4]
       
       mov eax,[iname_table + ebx*4]
       call print_str
       
       mov eax,newline
       call print_str
       
       mov eax,size_label
       call print_str
       
       mov ebx,[order_sizes + esi*4]
       
       cmp ebx,0
       je cart_regular
       
       mov eax,large_txt
       call print_str
       
       jmp cart_size_done

cart_regular:
       mov eax,regular_txt
       call print_str

cart_size_done:
       mov eax,newline
       call print_str
       
       mov eax,sugar_label
       call print_str
       
       mov ebx,[order_sugar + esi*4]
       
       mov eax,[sugar_table + ebx*4]
       call print_str
       
       mov eax,newline
       call print_str
       
       mov eax,ice_label
       call print_str
       
       mov ebx,[order_ice + esi*4]
       
       mov eax,[ice_table + ebx*4]
       call print_str
       
       mov eax,newline
       call print_str
       
       mov eax,qty_label
       call print_str
       
       mov eax,[order_qtys + esi*4]
       
       call print_int
       
       mov eax,newline
       call print_str
       
       mov eax,divider
       call print_str
       
       inc esi
       
       jmp cart_loop

cart_done:
       mov eax,cart_subtotal
       call print_str
       
       mov eax,[subtotal]
       
       call print_ringgit
       
       mov eax,newline
       call print_str
       
       mov eax,continue_menu
       call print_str
       
       mov eax,ask_continue
       call print_str
       
       mov eax,3
       mov ebx,0
       mov ecx,input_buf
       mov edx,32
       int 0x80
       
       movzx eax,byte [input_buf]
       
       cmp eax,'1'
       je order_loop
       
       cmp eax,'2'
       je checkout
       
       jmp show_cart

checkout:
       mov eax,receipt_hdr
       call print_str
       
       mov esi,0

receipt_loop:
       cmp esi,[order_count]
       jge receipt_done
       
       mov ebx,[order_items + esi*4]
       
       mov eax,[iname_table + ebx*4]
       call print_str
       
       mov eax,newline
       call print_str
       
       mov eax,size_label
       call print_str
       
       mov ebx,[order_sizes + esi*4]
       
       cmp ebx,0
       je print_regular
       
       mov eax,large_txt
       call print_str
       jmp size_done

print_regular:
       mov eax,regular_txt
       call print_str

size_done:
       mov eax,newline
       call print_str
       
       mov eax,sugar_label
       call print_str
       
       mov ebx,[order_sugar + esi*4]
       
       mov eax,[sugar_table + ebx*4]
       call print_str
       
       mov eax,newline
       call print_str
       
       mov eax,ice_label
       call print_str
       
       mov ebx,[order_ice + esi*4]
       
       mov eax,[ice_table + ebx*4]
       call print_str
       
       mov eax,newline
       call print_str
       
       mov eax,qty_label
       call print_str
       
       mov eax,[order_qtys + esi*4]
       call print_int
       
       mov eax,newline
       call print_str
       
       mov eax,amount_label
       call print_str
       
       mov ebx,[order_items + esi*4]
       
       mov ecx,[order_sizes + esi*4]
       
       cmp ecx,0
       je receipt_regular
       
       mov eax,[large_prices + ebx*4]
       jmp receipt_price_done

receipt_regular:
       mov eax,[regular_prices + ebx*4]

receipt_price_done:
       mov ebx,[order_qtys + esi*4]
       
       imul eax,ebx
       
       call print_ringgit
       
       mov eax,newline
       call print_str
       
       mov eax,divider
       call print_str
       
       inc esi
       jmp receipt_loop

receipt_done:
       mov eax,[subtotal]
       
       mov ebx,6
       
       imul eax,ebx
       
       xor edx,edx
       
       mov ebx,100
       
       div ebx
       
       mov [tax],eax
       
       mov eax,[subtotal]
       
       add eax,[tax]
       
       mov [total],eax
       
       mov eax,sub_label
       call print_str
       
       mov eax,[subtotal]
       call print_ringgit
       
       mov eax,newline
       call print_str
       
       mov eax,tax_label
       call print_str
       
       mov eax,[tax]
       call print_ringgit
       
       mov eax,newline
       call print_str
       
       mov eax,total_label
       call print_str
       
       mov eax,[total]
       call print_ringgit
       
       mov eax,newline
       call print_str

payment_section:
       mov eax,ask_payment
       call print_str
       
       mov eax,3
       mov ebx,0
       mov ecx,input_buf
       mov edx,32
       int 0x80
       
       call string_to_cents
       
       mov [payment],eax
       
       mov eax,[payment]
       
       cmp eax,[total]
       jl payment_section
       
       sub eax,[total]
       
       mov [change],eax
       
       mov eax,payment_label
       call print_str
       
       mov eax,[payment]
       call print_ringgit
       
       mov eax,newline
       call print_str
       
       mov eax,change_label
       call print_str
       
       mov eax,[change]
       call print_ringgit
       
       mov eax,newline
       call print_str
       
       mov eax,thankyou
       call print_str
       
       mov eax,1
       xor ebx,ebx
       int 0x80
    
print_ringgit:
       push eax
       push ebx
       push edx
       
       xor edx,edx
       
       mov ebx,100
       
       div ebx
       
       push edx
       
       call print_int
       
       mov eax,dot_str
       call print_str
       
       pop eax
       
       cmp eax,10
       jge ringgit_continue
       
       push eax
       
       mov eax,zero_pad
       call print_str
       
       pop eax

ringgit_continue:
       call print_int
       
       pop edx
       pop ebx
       pop eax
       
       ret

print_int:
       push eax
       push ebx
       push ecx
       push edx
       push edi
       
       mov edi,num_buf
       
       add edi,15
       
       mov byte [edi],0
       
       cmp eax,0
       jne convert_digits
       
       dec edi
       
       mov byte [edi],'0'
       
       jmp print_number

convert_digits:
       mov ebx,10

next_digit:
       xor edx,edx
       
       div ebx
       
       add dl,'0'
       
       dec edi
       
       mov [edi],dl
       
       test eax,eax
       
       jnz next_digit

print_number:
       mov eax,edi
       
       call print_str
       
       pop edi
       pop edx
       pop ecx
       pop ebx
       pop eax
       
       ret

print_str:
       push eax
       push ecx
       push edx
       
       mov ecx,eax
       
       xor edx,edx

find_length:
       cmp byte [ecx+edx],0
       je write_string
       
       inc edx
       
       jmp find_length

write_string:
       mov eax,4
       
       mov ebx,1
       
       int 0x80
       
       pop edx
       pop ecx
       pop eax
       
       ret

string_to_int:

       push ebx
       push ecx
       push edx
       push esi
       
       mov esi,input_buf
       
       xor eax,eax

string_to_cents:
       
       push ebx
       push ecx
       push edx
       push esi
       
       mov esi,input_buf
       
       xor eax,eax

whole_part:

       mov bl,[esi]
       
       cmp bl,'.'
       je decimal_part
       
       cmp bl,10
       je finish_whole
       
       cmp bl,13
       je finish_whole
       
       sub bl,'0'
       
       imul eax,eax,10
       
       movzx edx,bl
       
       add eax,edx
       
       inc esi
       
       jmp whole_part

finish_whole:

       imul eax,eax,100
       
       jmp done

decimal_part:

       imul eax,eax,100
       
       inc esi
       
       mov bl,[esi]
       
       sub bl,'0'
       
       movzx edx,bl
       
       imul edx,10
       
       add eax,edx
       
       inc esi
       
       mov bl,[esi]
       
       sub bl,'0'
       
       movzx edx,bl
       
       add eax,edx

done:

       pop esi
       pop edx
       pop ecx
       pop ebx
       
       ret

convert_loop:
       mov bl,[esi]
       
       cmp bl,10
       je convert_done
       
       cmp bl,13
       je convert_done
       
       cmp bl,0
       je convert_done
       
       cmp bl,'0'
       jl convert_done
       
       cmp bl,'9'
       jg convert_done
       
       imul eax,eax,10
       
       sub bl,'0'
       
       movzx edx,bl
       
       add eax,edx
       
       inc esi
       
       jmp convert_loop

convert_done:
       pop esi
       pop edx
       pop ecx
       pop ebx
       
       ret
