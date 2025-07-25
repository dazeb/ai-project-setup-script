# Testing Guide for AI Assistant Setup Script

This guide explains how to test all features of the AI assistant setup script to ensure everything works correctly.

## 🧪 Test Scripts Overview

### **1. `run-tests.sh` - Basic Validation**
- **Purpose**: Validates the current directory setup
- **Usage**: `./run-tests.sh [validate]`
- **Tests**: VS Code workspace, MCP tools, TypeScript/React rules, AI assistant configurations

### **2. `test-all-assistants.sh` - Comprehensive Testing**
- **Purpose**: Tests all AI assistants and features
- **Usage**: `./test-all-assistants.sh [quick|full|validate]`
- **Tests**: All AI assistants, project creation, template files

### **3. `test-setup.sh` - Detailed Test Suite**
- **Purpose**: Comprehensive test suite with detailed validation
- **Usage**: `./test-setup.sh [validate]`
- **Tests**: All components with detailed reporting

## 🚀 Quick Start Testing

### **1. Quick Validation**
```bash
# Test that all required files exist
./test-all-assistants.sh quick
```

### **2. Test Single AI Assistant**
```bash
# Create test project and validate
mkdir test-project && cd test-project
cp ../setup.sh . && cp -r ../src .
./setup.sh  # Choose AI assistant and option 1
cp ../run-tests.sh . && ./run-tests.sh validate
```

### **3. Test All AI Assistants**
```bash
# Comprehensive test of all assistants (takes ~5 minutes)
./test-all-assistants.sh full
```

## 📋 Manual Testing Checklist

### **Pre-Test Setup**
- [ ] Ensure `setup.sh` is executable: `chmod +x setup.sh`
- [ ] Verify all template files exist in `src/` directory
- [ ] Check TypeScript/React rule files are in `src/`

### **Test Each AI Assistant**

#### **GitHub Copilot (Option 1)**
- [ ] Run setup and choose option 1
- [ ] Choose "Configure current directory" (option 1)
- [ ] Verify `.github/` directory created
- [ ] Check `.github/copilot-instructions.md` exists
- [ ] Verify `.github/instructions/` and `.github/prompts/` directories
- [ ] Confirm `.vscode/` workspace created
- [ ] Validate TypeScript/React rules copied

#### **Cline (Option 2)**
- [ ] Run setup and choose option 2
- [ ] Choose "Configure current directory" (option 1)
- [ ] Verify `.clinerules/` directory created
- [ ] Check `clinerules-bank/` directory exists
- [ ] Confirm rule files in `.clinerules/`
- [ ] Verify TypeScript/React rules as `.md` files
- [ ] Check `.vscode/` workspace created

#### **Cursor (Option 3)**
- [ ] Run setup and choose option 3
- [ ] Choose "Configure current directory" (option 1)
- [ ] Verify `.cursor/rules/` directory created
- [ ] Check `cursor-rules-bank/` directory exists
- [ ] Confirm `.mdc` rule files in `.cursor/rules/`
- [ ] Verify TypeScript/React rules as `.mdc` files
- [ ] Check template files created

#### **Windsurf (Option 4)**
- [ ] Run setup and choose option 4
- [ ] Choose "Configure current directory" (option 1)
- [ ] Verify `.windsurf/rules/` directory created
- [ ] Check `windsurf-rules-bank/` directory exists
- [ ] Confirm rule files in `.windsurf/rules/`
- [ ] Verify `global_rules.md` created
- [ ] Check TypeScript/React rules copied

#### **Augment (Option 5)**
- [ ] Run setup and choose option 5
- [ ] Choose "Configure current directory" (option 1)
- [ ] Verify `.augment/rules/` directory created
- [ ] Check `.augment-guidelines` file exists
- [ ] Confirm rule files in `.augment/rules/`
- [ ] Verify TypeScript/React rules as `.md` files

#### **Roo Code (Option 6)**
- [ ] Run setup and choose option 6
- [ ] Choose "Configure current directory" (option 1)
- [ ] Verify `.roo/rules/` and mode-specific directories created
- [ ] Check `roo-rules-bank/` directory exists
- [ ] Confirm `.roorules` file created
- [ ] Verify TypeScript/React rules in `.roo/rules-code/`

### **Test Project Creation**
- [ ] Run setup and choose any AI assistant
- [ ] Choose "Create new project" (option 2)
- [ ] Enter project name: `test-project`
- [ ] Verify project directory created
- [ ] Check all AI assistant files copied to project
- [ ] Confirm template files copied
- [ ] Validate `package.json` and `.gitignore` created

## 🔍 What Each Test Validates

### **VS Code Workspace Tests**
- `.vscode/settings.json` - VS Code configuration
- `.vscode/mcp.json` - Model Context Protocol tools
- `.vscode/tasks.json` - AI assistant tasks
- `.vscode/launch.json` - Debug configuration

### **MCP Tools Tests**
- `file_reader` tool configuration
- `code_analyzer` tool configuration
- `test_generator` tool configuration
- `security_analyzer` tool configuration
- Resource definitions for project files
- Prompt definitions for common tasks

### **TypeScript/React Rules Tests**
- TypeScript rules copied to appropriate directories
- ShadCN UI component rules available
- Tailwind CSS utility rules included
- Format conversion (MDC → Markdown) working
- Rules accessible by each AI assistant

### **AI Assistant Specific Tests**
- Correct directory structure created
- Rule files in proper format
- Template files copied
- Configuration files generated
- Integration with VS Code workspace

## 🐛 Troubleshooting

### **Common Issues**

#### **Setup Script Not Executable**
```bash
chmod +x setup.sh
chmod +x run-tests.sh
chmod +x test-all-assistants.sh
```

#### **Missing Template Files**
```bash
# Verify all files exist
ls -la src/
# Should show: requirements.md, design.md, tasks.md, typescript.mdc, shadcn-ui.mdc, tailwind.mdc
```

#### **Test Failures**
```bash
# Run detailed validation
./run-tests.sh validate

# Check specific AI assistant
cd test-directory
./run-tests.sh validate
```

#### **Permission Errors**
```bash
# Fix permissions
chmod +x *.sh
chmod -R 755 src/
```

## 📊 Expected Test Results

### **Successful Test Output**
```
✓ VS Code directory
✓ VS Code settings
✓ MCP configuration
✓ TypeScript rules
✓ ShadCN UI rules
✓ Tailwind CSS rules
✓ AI assistant configuration

Total Tests: 15
Passed: 15
Failed: 0
All tests passed! ✅
```

### **Test Failure Example**
```
✓ VS Code directory
✗ VS Code settings (missing: .vscode/settings.json)
✓ MCP configuration

Total Tests: 15
Passed: 12
Failed: 3
Some tests failed! ❌
```

## 🎯 Continuous Testing

### **Before Commits**
```bash
# Quick validation
./test-all-assistants.sh quick

# Full test suite
./test-all-assistants.sh full
```

### **After Changes**
```bash
# Test specific feature
mkdir test-feature && cd test-feature
cp ../setup.sh . && cp -r ../src .
./setup.sh  # Test your changes
```

This testing suite ensures that all AI assistant configurations work correctly and that users get a consistent, professional setup experience regardless of which AI assistant they choose.
