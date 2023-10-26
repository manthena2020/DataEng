x = input("enter the required string:")
ip = list(x) # converting the input string into list

# Create two lists, one for alphabets and one for digits
alpha= []
digit = []
for char in ip:
    if char.isalpha():
        alpha.append(char)
    else:
        digit.append(char)

# Reverse the list of alphabets
alpha.reverse()

# Merge the two lists back into a single list
op = []
for char in ip:
    if char.isalpha():
        op.append(alpha.pop(0))
    else:
        op.append(digit.pop(0))

# Convert the list back to a string
os = ''.join(op)

print(os)
