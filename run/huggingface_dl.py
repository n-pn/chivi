# from huggingface_hub import login
# login()

from huggingface_hub import snapshot_download
snapshot_download(repo_id="jetaudio/zh_novels", local_dir_use_symlinks=False, local_dir="/2tb/huggingface")
