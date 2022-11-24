# Music ROM generator
# TODO: Add rest in between each note
# TODO: Add "extend" (idk music terms) and use char '-'

print("Type in C,D,E,F,G,A,B for notes.\nType in x for rest.")
str = input("Notes:")
str = str.ljust(64, 'x')
print(str)

for i in str:
  if i == " ":
    continue
  elif i == "X" or i == "x":
    print("0000000")
  elif i == "C" or i == "c":
    print("1000000")
  elif i == "D" or i == "d":
    print("0100000")
  elif i == "E" or i == "e":
    print("0010000")
  elif i == "F" or i == "f":
    print("0001000")
  elif i == "G" or i == "g":
    print("0000100")
  elif i == "A" or i == "a":
    print("0000010")
  elif i == "B" or i == "b":
    print("0000001")
  else:
    print("0000000")
