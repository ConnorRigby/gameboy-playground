import png
import sys

smiley = open("smiley-8x8.2bpp", "rb")
data = smiley.read()
# print(len(data))
print(format(data[0], "04b"), end=" ")
print(format(data[1], "04b"), end=" ")
print(format(data[2], "04b"), end=" ")
print(format(data[3], "04b"))


print("\r\n=====")

# surprised-pika-160x144.png
fd = open("smiley-8x8.png", "rb")
image = png.Reader(file=fd)
data = image.read()
width = data[0]
height = data[1]
pixels = list(data[2])
for x, row in enumerate(pixels):
    for y in range(round(len(row) / 3)):
        print(f"{x},{y}: rgb({row[y]}, {row[y+1]}, {row[y+2]})")
