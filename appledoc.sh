/usr/local/bin/appledoc \
    --project-name "KKBOXOpenAPI" \
    --project-company "KKBOX Inc." \
    --company-id "com.kkbox" \
    --output "./appledoc" \
	--verbose 5 \
    --publish-docset \
    --logformat xcode \
    --keep-intermediate-files \
    --no-repeat-first-par \
    --no-warn-invalid-crossref \
    --ignore "*.m" \
    --index-desc "./README.md" \
    "./KKBOXOpenAPI/." 
