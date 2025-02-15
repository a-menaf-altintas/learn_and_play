#!/usr/bin/env python3

import os

def main():
    # Use the current working directory as the project path
    project_path = os.getcwd()

    for root, dirs, files in os.walk(project_path):
        for filename in files:
            if filename.endswith(".dart"):
                full_path = os.path.join(root, filename)
                print(f"\n--- FILE: {full_path} ---")
                try:
                    with open(full_path, "r", encoding="utf-8") as dart_file:
                        print(dart_file.read())
                except Exception as e:
                    print(f"ERROR reading {full_path}: {e}")
                print("--- END OF FILE ---")

if __name__ == "__main__":
    main()
