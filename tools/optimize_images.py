from PIL import Image
import os

root = os.path.dirname(os.path.dirname(__file__))
img_dir = os.path.join(root, 'assets', 'images')
wall = os.path.join(img_dir, 'wallpaper.jpg')
backup = os.path.join(img_dir, 'wallpaper.original.jpg')
optimized = os.path.join(img_dir, 'wallpaper.jpg')

if not os.path.exists(wall):
    print('No wallpaper found at', wall)
    raise SystemExit(1)

# create backup if not exists
if not os.path.exists(backup):
    os.rename(wall, backup)
    print('Backup created:', backup)
    src = backup
else:
    print('Backup already exists, using backup as source')
    src = backup

with Image.open(src) as img:
    w, h = img.size
    max_w = 1920
    if w > max_w:
        new_h = int(h * (max_w / w))
        img = img.resize((max_w, new_h), Image.LANCZOS)
        print(f'Resized from {w}x{h} to {max_w}x{new_h}')
    else:
        print(f'No resize needed ({w}x{h})')

    # save optimized
    img.save(optimized, 'JPEG', quality=75, optimize=True)
    orig_size = os.path.getsize(src)
    new_size = os.path.getsize(optimized)
    print(f'Optimized saved: {optimized}')
    print(f'Size: {orig_size} -> {new_size} bytes')
