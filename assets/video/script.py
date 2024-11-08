import subprocess
import os

def convert_video(input_num):
    input_file = f'output_step_{input_num}.mp4'
    output_file = f'output_video_{input_num}.mp4'
    
    # Skip if input file doesn't exist
    if not os.path.exists(input_file):
        print(f"Skipping {input_file} - file not found")
        return
    
    # FFmpeg command
    cmd = [
        'ffmpeg',
        '-i', input_file,
        '-c:v', 'libx264',
        '-profile:v', 'baseline',
        '-level', '3.1',
        '-b:v', '2M',
        '-maxrate', '2M',
        '-bufsize', '2M',
        '-vf', 'scale=-2:720',
        '-r', '30',
        '-c:a', 'aac',
        '-b:a', '128k',
        '-ar', '44100',
        output_file
    ]
    
    print(f"Converting {input_file} to {output_file}...")
    try:
        subprocess.run(cmd, check=True)
        print(f"Successfully converted {input_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error converting {input_file}: {e}")

def main():
    # Convert videos from 1 to 19
    for i in range(1, 20):
        convert_video(i)

if __name__ == "__main__":
    main()
