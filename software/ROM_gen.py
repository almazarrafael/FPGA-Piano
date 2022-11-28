# Music ROM generator

prev = ""
fileName = ""

def main ():
  global prev, j
  print("Type in C,D,E,F,G,A,B for notes.\nType in x for rest.\nType in - for extending the note.\n")
  str = input("Notes: ")
  str = str.ljust(64, 'x')
  fileName = input("\nType in name of song: \n")
  f = open(fileName + ".txt", 'w')

  for i in str:
    decode = decoder(i, prev)
    f.write(decode + "\n")
    prev = i
    if (i == "-"):
      pass
    else:
      f.write("0000000\n")

  
def decoder(note, prev):
  if (note == '-'):
    return decoder(prev, "")

  # Python doesn't have a switch case. L.
  if note == " ":
    pass
  elif note == "X" or note == "x":
    return "0000000"
  elif note == "C" or note == "c":
    return "1000000"
  elif note == "D" or note == "d":
    return "0100000"
  elif note == "E" or note == "e":
    return "0010000"
  elif note == "F" or note == "f":
    return "0001000"
  elif note == "G" or note == "g":
    return "0000100"
  elif note == "A" or note == "a":
    return "0000010"
  elif note == "B" or note == "b":
    return "0000001"
  else:
    return "0000000"

if __name__ == "__main__":
  main()
  print("\nROM file has been generated.")
