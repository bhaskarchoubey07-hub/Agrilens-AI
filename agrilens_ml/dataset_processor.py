import os
import shutil
import hashlib
import random
from PIL import Image

class DatasetProcessor:
    def __init__(self, raw_data_dir, output_data_dir="data", split_ratio=(0.7, 0.2, 0.1)):
        """
        raw_data_dir: Path to raw downloaded images grouped by folders/categories.
        output_data_dir: Path where train/val/test splits will be structured.
        split_ratio: Tuple representing (train, val, test) proportions.
        """
        self.raw_data_dir = raw_data_dir
        self.output_data_dir = output_data_dir
        self.split_ratio = split_ratio
        
    def _calculate_md5(self, file_path):
        """Calculates MD5 hash to detect duplicate files."""
        hasher = hashlib.md5()
        with open(file_path, 'rb') as f:
            buf = f.read(65536)
            while len(buf) > 0:
                hasher.update(buf)
                buf = f.read(65536)
        return hasher.hexdigest()

    def clean_and_split(self):
        """Clean corrupted files, remove duplicates, and split into train/val/test."""
        print(f"Starting dataset processing. Reading from: {self.raw_data_dir}")
        
        # Resolve folders representing categories
        categories = [d for d in os.listdir(self.raw_data_dir) 
                      if os.path.isdir(os.path.join(self.raw_data_dir, d))]
        
        seen_hashes = set()
        cleaned_count = 0
        duplicate_count = 0
        processed_stats = {}

        # Reset output directories
        for split in ['train', 'val', 'test']:
            split_dir = os.path.join(self.output_data_dir, split)
            if os.path.exists(split_dir):
                shutil.rmtree(split_dir)
            os.makedirs(split_dir, exist_ok=True)

        for category in categories:
            cat_raw_dir = os.path.join(self.raw_data_dir, category)
            print(f"Processing category: {category}...")
            
            # Setup split target folders
            for split in ['train', 'val', 'test']:
                os.makedirs(os.path.join(self.output_data_dir, split, category), exist_ok=True)

            valid_files = []
            file_names = os.listdir(cat_raw_dir)
            
            for file_name in file_names:
                file_path = os.path.join(cat_raw_dir, file_name)
                
                # Filter non-files
                if not os.path.isfile(file_path):
                    continue
                
                # Check 1: Try reading with PIL to identify corruption
                try:
                    with Image.open(file_path) as img:
                        img.verify() # Verify image integrity
                except Exception:
                    print(f"Removing corrupted image: {file_path}")
                    cleaned_count += 1
                    continue
                
                # Check 2: Check for duplicates using MD5
                file_hash = self._calculate_md5(file_path)
                if file_hash in seen_hashes:
                    duplicate_count += 1
                    continue
                
                seen_hashes.add(file_hash)
                valid_files.append(file_path)

            # Shuffle to ensure random distributions
            random.seed(42)
            random.shuffle(valid_files)

            # Split indices calculation
            total_valid = len(valid_files)
            train_idx = int(total_valid * self.split_ratio[0])
            val_idx = train_idx + int(total_valid * self.split_ratio[1])

            train_files = valid_files[:train_idx]
            val_files = valid_files[train_idx:val_idx]
            test_files = valid_files[val_idx:]

            # Copy files to designated folders
            for files_list, split_name in [(train_files, 'train'), (val_files, 'val'), (test_files, 'test')]:
                for f in files_list:
                    dest = os.path.join(self.output_data_dir, split_name, category, os.path.basename(f))
                    shutil.copy2(f, dest)

            processed_stats[category] = {
                "total": total_valid,
                "train": len(train_files),
                "val": len(val_files),
                "test": len(test_files)
            }
            print(f"Category '{category}' split: {len(train_files)} train, {len(val_files)} val, {len(test_files)} test.")

        print("\n=== Dataset Processing Summary ===")
        print(f"Corrupted Images Cleaned: {cleaned_count}")
        print(f"Duplicate Images Removed: {duplicate_count}")
        print("Folder split layout created successfully.")
        
        return processed_stats

if __name__ == "__main__":
    # Example execution: python dataset_processor.py path/to/raw/dataset
    import sys
    if len(sys.argv) < 2:
        print("Usage: python dataset_processor.py <raw_dataset_directory>")
    else:
        processor = DatasetProcessor(sys.argv[1])
        processor.clean_and_split()
