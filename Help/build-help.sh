#!/bin/bash

# Gowi Help Documentation Build Script
# Converts Markdown source files to Apple Help Book format
#
# This script:
# 1. Converts Markdown files to HTML using pandoc
# 2. Applies Apple Help Book styling and structure
# 3. Generates the help index and navigation
# 4. Creates the complete help book directory structure

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/Source"
OUTPUT_DIR="$SCRIPT_DIR/Generated"
TEMPLATE_DIR="$SCRIPT_DIR/Templates"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[Help Build]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[Help Build Warning]${NC} $1"
}

error() {
    echo -e "${RED}[Help Build Error]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[Help Build Success]${NC} $1"
}

# Check dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    if ! command -v pandoc &> /dev/null; then
        error "pandoc is required but not installed. Install with: brew install pandoc"
    fi
    
    success "All dependencies found"
}

# Clean output directory
clean_output() {
    log "Cleaning output directory..."
    rm -rf "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR/Contents/Resources/English.lproj"
}

# Generate help book structure
generate_help_structure() {
    log "Generating help book structure..."
    
    # Create Info.plist for the help book
    cat > "$OUTPUT_DIR/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIdentifier</key>
    <string>com.self.Gowi.help</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Gowi Help</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleSignature</key>
    <string>hbwr</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>HPDBookAccessPath</key>
    <string>English.lproj/index.html</string>
    <key>HPDBookIndexPath</key>
    <string>English.lproj/search.helpindex</string>
    <key>HPDBookTitle</key>
    <string>Gowi Help</string>
    <key>HPDBookType</key>
    <string>3</string>
</dict>
</plist>
EOF
}

# Convert individual markdown file to HTML
convert_markdown_file() {
    local md_file="$1"
    local output_file="$2"
    local title="$3"
    
    log "Converting $md_file to $output_file"
    
    # Use pandoc to convert markdown to HTML with custom template
    pandoc \
        --from markdown \
        --to html5 \
        --standalone \
        --template="$TEMPLATE_DIR/help-page.html" \
        --variable title="$title" \
        --variable app-name="Gowi" \
        --css="help.css" \
        --output="$output_file" \
        "$md_file"
}

# Convert all markdown files
convert_markdown_files() {
    log "Converting Markdown files to HTML..."
    
    local english_dir="$OUTPUT_DIR/Contents/Resources/English.lproj"
    
    # Convert each markdown file
    if [[ -f "$SOURCE_DIR/index.md" ]]; then
        convert_markdown_file "$SOURCE_DIR/index.md" "$english_dir/index.html" "Gowi Help"
    fi
    
    if [[ -f "$SOURCE_DIR/getting-started.md" ]]; then
        convert_markdown_file "$SOURCE_DIR/getting-started.md" "$english_dir/getting-started.html" "Getting Started"
    fi
    
    if [[ -f "$SOURCE_DIR/features.md" ]]; then
        convert_markdown_file "$SOURCE_DIR/features.md" "$english_dir/features.html" "Features"
    fi
    
    if [[ -f "$SOURCE_DIR/tips-and-tricks.md" ]]; then
        convert_markdown_file "$SOURCE_DIR/tips-and-tricks.md" "$english_dir/tips-and-tricks.html" "Tips and Tricks"
    fi
}

# Copy static assets
copy_assets() {
    log "Copying static assets..."
    
    local english_dir="$OUTPUT_DIR/Contents/Resources/English.lproj"
    
    # Copy CSS file
    if [[ -f "$TEMPLATE_DIR/help.css" ]]; then
        cp "$TEMPLATE_DIR/help.css" "$english_dir/"
    fi
    
    # Copy any images
    if [[ -d "$SOURCE_DIR/images" ]]; then
        cp -r "$SOURCE_DIR/images" "$english_dir/"
    fi
}

# Deploy help to app bundle
deploy_to_app() {
    log "Deploying help book to app bundle..."
    
    # Check if we're being called from Xcode build
    if [[ -n "$BUILT_PRODUCTS_DIR" && -n "$CONTENTS_FOLDER_PATH" ]]; then
        # Running as Xcode build phase - Apple Help Books need to be in English.lproj
        local app_help_dir="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Resources/English.lproj/GowiHelp"
        log "Xcode build detected - deploying to: $app_help_dir"
        
        # Create English.lproj directory if needed
        mkdir -p "$(dirname "$app_help_dir")"
        
        # Remove old help book
        rm -rf "$app_help_dir"
        
        # Copy new help book
        cp -r "$OUTPUT_DIR" "$app_help_dir"
        success "Help book deployed to app bundle"
    else
        # Running standalone - just log the location
        log "Standalone build - help book available at: $OUTPUT_DIR"
        log "To deploy to app, run this script as an Xcode build phase"
    fi
}

# Generate help index
generate_help_index() {
    log "Generating help search index..."
    
    local english_dir="$OUTPUT_DIR/Contents/Resources/English.lproj"
    
    # Apple's hiutil command generates the search index
    if command -v hiutil &> /dev/null; then
        hiutil -C -a -s en -f "$english_dir/search.helpindex" "$english_dir"
        success "Help search index generated"
    else
        warn "hiutil not found - help search will not be available"
    fi
}

# Main build process
main() {
    log "Starting help documentation build process..."
    
    check_dependencies
    clean_output
    generate_help_structure
    convert_markdown_files
    copy_assets
    generate_help_index
    deploy_to_app
    
    success "Help documentation build completed successfully!"
    log "Output directory: $OUTPUT_DIR"
}

# Run the build process
main "$@"