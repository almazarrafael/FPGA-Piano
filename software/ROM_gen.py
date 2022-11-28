# Music ROM generator

prev = ""

def main ():
  global prev, j
  print("Type in C,D,E,F,G,A,B for notes.\nType in x for rest.\nType in - for extending the note.\n")
  str = input("Notes:")
  str = str.ljust(64, 'x')
  print(str)

  for i in str:
    decoder(i, prev)
    prev = i
    if (i == "-"):
      pass
    else:
      print("0000000")

  
def decoder(note, prev):
  if (note == '-'):
    decoder(prev, "")
    return

  # Python doesn't have a switch case. L.
  if note == " ":
    pass
  elif note == "X" or note == "x":
    print("0000000")
  elif note == "C" or note == "c":
    print("1000000")
  elif note == "D" or note == "d":
    print("0100000")
  elif note == "E" or note == "e":
    print("0010000")
  elif note == "F" or note == "f":
    print("0001000")
  elif note == "G" or note == "g":
    print("0000100")
  elif note == "A" or note == "a":
    print("0000010")
  elif note == "B" or note == "b":
    print("0000001")
  else:
    print("0000000")

if __name__ == "__main__":
  main()
