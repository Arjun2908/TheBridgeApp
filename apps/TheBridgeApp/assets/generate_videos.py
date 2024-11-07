import os

# List of steps (assuming this is from your existing setup)
steps = [
    {
        "startFrom": 0,
        "endAt": 3.5
    },
    {
        "startFrom": 5,
        "endAt": 7
    },
    {
        "startFrom": 9.0,  # adjusted by 0.5s
        "endAt": 11.8
    },
    {
        "startFrom": 14,
        "endAt": 16.5
    },
    {
        "startFrom": 18.5,
        "endAt": 22
    },
    {
        "startFrom": 23.5,
        "endAt": 26
    },
    {
        "startFrom": 28.5,
        "endAt": 31.2
    },
    {
        "startFrom": 33.5,
        "endAt": 37
    },
    {
        "startFrom": 39.0,  # adjusted by 0.5s
        "endAt": 42
    },
    {
        "startFrom": 44.0,  # adjusted by 0.5s
        "endAt": 47
    },
    {
        "startFrom": 49,
        "endAt": 53
    },
    {
        "startFrom": 55,
        "endAt": 57.3
    },
    {
        "startFrom": 59.0,  # adjusted by 0.5s
        "endAt": 62
    },
    {
        "startFrom": 64.5,
        "endAt": 70.5
    },
    {
        "startFrom": 72.5,
        "endAt": 78
    },
    {
        "startFrom": 80,
        "endAt": 86.5
    },
    {
        "startFrom": 87.8,
        "endAt": 92
    },
    {
        "startFrom": 93.5,
        "endAt": 113
    },
    {
        "startFrom": 114.5,
        "endAt": 118
    }
];


# Input video filename
input_video = "bridge_diagram.mp4"

# Generate FFmpeg commands for each step
for index, step in enumerate(steps):
    start_time = step["startFrom"]
    end_time = step["endAt"]
    duration = end_time - start_time  # Calculate the duration for each step

    # Output filename for each step
    output_video = f"output_step_{index + 1}.mp4"

    # FFmpeg command
    ffmpeg_command = f"ffmpeg -ss {start_time} -i {input_video} -t {duration} -c copy {output_video}"

    # Run the FFmpeg command
    print(f"Executing: {ffmpeg_command}")
    os.system(ffmpeg_command)

print("Video segments generated for each step.")
