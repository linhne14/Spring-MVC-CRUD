# 🚨 GITHUB PUSH PROTECTION FIX

## Bước 1: Tạo .gitignore để loại trừ secrets
echo "# Secrets and sensitive files" >> .gitignore
echo "**/alertmanager-full-config.yaml" >> .gitignore
echo "**/*secret*" >> .gitignore
echo "**/*password*" >> .gitignore
echo ".env" >> .gitignore

## Bước 2: Remove files có secrets khỏi git tracking
git rm --cached monitoring/alertmanager-full-config.yaml

## Bước 3: Reset về commit trước đó (safe)
# Option A: Soft reset (giữ lại changes trong working directory)
git reset --soft HEAD~1

# Option B: Hard reset (mất hết changes - CAREFUL!)
# git reset --hard HEAD~1

## Bước 4: Tạo commit mới với files clean
git add .
git commit -m "Add monitoring stack without secrets"

## Bước 5: Force push (nếu đã push trước đó)
# git push --force-with-lease origin main