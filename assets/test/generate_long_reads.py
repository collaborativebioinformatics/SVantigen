import gzip

seq = "ACGT" * 25  # 100 bp reference sequence
tumor_seq = seq[:40] + seq[50:]  # 90 bp sequence with a 10 bp deletion

with open("assets/test/tumor_long.fastq", "w") as f:
    f.write(f"@read_long_tumor\n{tumor_seq}\n+\n{'I'*len(tumor_seq)}\n")

with open("assets/test/normal_long.fastq", "w") as f:
    f.write(f"@read_long_normal\n{seq}\n+\n{'I'*len(seq)}\n")
