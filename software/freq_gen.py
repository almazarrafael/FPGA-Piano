# Code for calculating max clock divider value
freq = 4
clock_speed = 125000000
result = round(clock_speed/freq)

print(bin(result)[2:].zfill(27))
