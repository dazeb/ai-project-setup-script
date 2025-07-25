#!/usr/bin/env bash

# AI Project Setup Script
# Automated setup for AI coding assistants with professional configurations
#
# Usage: ./setup.sh [options]
# Options:
#   -h, --help     Show this help message
#   -v, --version  Show version information
#   --no-color     Disable colored output
#   --dry-run      Show what would be done without making changes

# Enable strict mode for safer script execution
set -euo pipefail
IFS=$'\n\t'

# Script version and metadata
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_NAME="AI Project Setup Script"

# Global variables
ENABLE_COLOR=true
DRY_RUN=false

# Colors for output (only if terminal supports it)
if [[ -t 1 ]] && [[ "${ENABLE_COLOR}" == "true" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly PURPLE='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly NC='\033[0m' # No Color
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly PURPLE=''
    readonly CYAN=''
    readonly NC=''
fi

# Function to print colored output
print_color() {
    local color="$1"
    local message="$2"
    if [[ "${ENABLE_COLOR}" == "true" ]] && [[ -t 1 ]]; then
        echo -e "${color}${message}${NC}"
    else
        echo "${message}"
    fi
}

# Function to show usage information
usage() {
    cat << EOF
${SCRIPT_NAME} v${SCRIPT_VERSION}

USAGE:
    $0 [OPTIONS]

DESCRIPTION:
    Automated setup script for AI coding assistants including GitHub Copilot,
    Cline, Cursor, Windsurf, Augment, and Roo Code. Creates professional
    configuration files, rules, and project structures.

OPTIONS:
    -h, --help      Show this help message and exit
    -v, --version   Show version information and exit
    --no-color      Disable colored output
    --dry-run       Show what would be done without making changes
    --assistant     Specify AI assistant (copilot|cline|cursor|windsurf|augment|roo)

EXAMPLES:
    $0                          # Interactive setup
    $0 --assistant cursor       # Setup Cursor only
    $0 --dry-run               # Preview changes without applying
    $0 --no-color              # Run without colored output

REQUIREMENTS:
    - Bash 4.0 or higher
    - Git (for project initialization)
    - VS Code (optional, for extension installation)

For more information, visit: https://github.com/dazeb/ai-project-setup-script
EOF
}

# Function to show version information
show_version() {
    echo "${SCRIPT_NAME} v${SCRIPT_VERSION}"
    echo "Bash version: ${BASH_VERSION}"
    echo "Platform: $(uname -s) $(uname -m)"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check required dependencies
check_dependencies() {
    local missing_deps=()

    # Check for required commands
    if ! command_exists "bash"; then
        missing_deps+=("bash")
    fi

    # Check Bash version (require 4.0+)
    if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
        print_color "${RED}" "Error: Bash 4.0 or higher is required. Current version: ${BASH_VERSION}"
        exit 1
    fi

    # Check for optional but recommended commands
    local optional_deps=("git" "curl" "code")
    local missing_optional=()

    for cmd in "${optional_deps[@]}"; do
        if ! command_exists "$cmd"; then
            missing_optional+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_color "${RED}" "Error: Missing required dependencies:"
        printf '%s\n' "${missing_deps[@]}"
        exit 1
    fi

    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        print_color "${YELLOW}" "Warning: Missing optional dependencies (some features may be limited):"
        printf '%s\n' "${missing_optional[@]}"
        echo
    fi
}

# Function to print section headers
print_header() {
    echo
    print_color "${CYAN}" "============================================"
    print_color "${CYAN}" "$1"
    print_color "${CYAN}" "============================================"
    echo
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            --no-color)
                ENABLE_COLOR=false
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --assistant)
                if [[ -n "${2:-}" ]]; then
                    AI_ASSISTANT="$2"
                    shift 2
                else
                    print_color "${RED}" "Error: --assistant requires a value"
                    exit 1
                fi
                ;;
            *)
                print_color "${RED}" "Error: Unknown option '$1'"
                echo "Use '$0 --help' for usage information."
                exit 1
                ;;
        esac
    done
}

# Function to confirm destructive actions
confirm_action() {
    local message="$1"
    local default="${2:-n}"

    if [[ "${DRY_RUN}" == "true" ]]; then
        print_color "${BLUE}" "[DRY RUN] Would ask: ${message}"
        return 0
    fi

    local prompt
    if [[ "${default}" == "y" ]]; then
        prompt="${message} [Y/n] "
    else
        prompt="${message} [y/N] "
    fi

    read -p "${prompt}" response
    response="${response:-${default}}"

    [[ "${response}" =~ ^[Yy]$ ]]
}

# Utility function for safe directory creation
safe_mkdir() {
    local dirs=("$@")

    if [[ "${DRY_RUN}" == "true" ]]; then
        print_color "${BLUE}" "[DRY RUN] Would create directories: ${dirs[*]}"
        return 0
    fi

    for dir in "${dirs[@]}"; do
        if [[ -z "${dir}" ]]; then
            print_color "${RED}" "Error: Empty directory name provided"
            return 1
        fi

        if ! mkdir -p "${dir}"; then
            print_color "${RED}" "Failed to create directory: ${dir}"
            return 1
        fi
        print_color "${GREEN}" "Created directory: ${dir}"
    done
}

# Utility function for safe file creation
create_file() {
    local filepath="$1"
    local content="$2"

    if [[ -z "${filepath}" ]]; then
        print_color "${RED}" "Error: Empty filepath provided"
        return 1
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
        print_color "${BLUE}" "[DRY RUN] Would create file: ${filepath}"
        return 0
    fi

    # Ensure directory exists
    local dir
    dir="$(dirname "${filepath}")"
    if [[ ! -d "${dir}" ]]; then
        safe_mkdir "${dir}" || return 1
    fi

    if ! echo "${content}" > "${filepath}"; then
        print_color "${RED}" "Failed to create file: ${filepath}"
        return 1
    fi

    print_color "${GREEN}" "Created file: ${filepath}"
}

# Utility function for creating rule files with error handling
create_rule_file() {
    local filepath="$1"
    local content="$2"

    if [[ -z "${filepath}" || -z "${content}" ]]; then
        print_color "${RED}" "Error: filepath and content are required for create_rule_file"
        return 1
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
        print_color "${BLUE}" "[DRY RUN] Would create rule file: ${filepath}"
        return 0
    fi

    # Ensure directory exists
    local dir
    dir="$(dirname "${filepath}")"
    safe_mkdir "${dir}" || return 1

    # Create file with content using a more robust method
    if ! cat > "${filepath}" << EOF
${content}
EOF
    then
        print_color "${RED}" "Failed to create rule file: ${filepath}"
        return 1
    fi

    print_color "${GREEN}" "Created rule file: ${filepath}"
}

# Utility function for copying files with error handling
safe_copy() {
    local source="$1"
    local destination="$2"

    if [[ -z "${source}" || -z "${destination}" ]]; then
        print_color "${RED}" "Error: source and destination are required for safe_copy"
        return 1
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
        print_color "${BLUE}" "[DRY RUN] Would copy ${source} to ${destination}"
        return 0
    fi

    if [[ -f "${source}" ]]; then
        # Ensure destination directory exists
        local dest_dir
        dest_dir="$(dirname "${destination}")"
        safe_mkdir "${dest_dir}" || return 1

        if cp "${source}" "${destination}" 2>/dev/null; then
            print_color "${GREEN}" "Copied ${source} to ${destination}"
        else
            print_color "${YELLOW}" "Warning: Failed to copy ${source} to ${destination}"
            return 1
        fi
    else
        print_color "${YELLOW}" "Warning: Source file ${source} does not exist"
        return 1
    fi
}

# Utility function for automatic global rules placement
place_global_rules() {
    local assistant_name="$1"
    local rules_content="$2"
    local global_path="$3"

    if [[ -z "${assistant_name}" || -z "${rules_content}" || -z "${global_path}" ]]; then
        print_color "${RED}" "Error: All parameters are required for place_global_rules"
        return 1
    fi

    if [[ -f "${global_path}" ]]; then
        print_color "${YELLOW}" "Global rules already exist at ${global_path}. Skipping to avoid overwrite."
        return 0
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
        print_color "${BLUE}" "[DRY RUN] Would create global rules for ${assistant_name} at ${global_path}"
        return 0
    fi

    safe_mkdir "$(dirname "${global_path}")" || return 1
    create_rule_file "${global_path}" "${rules_content}" || return 1
    print_color "${GREEN}" "Global rules template created for ${assistant_name} at ${global_path}"
}

# Function to copy TypeScript/React rule files if they exist
copy_typescript_react_rules() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local src_dir="$script_dir/src"

    # Copy TypeScript, ShadCN UI, and Tailwind CSS rules if they exist
    if [[ -f "$src_dir/typescript.mdc" ]]; then
        print_color $YELLOW "Adding TypeScript rules..."
        cp "$src_dir/typescript.mdc" .cursor/rules/ 2>/dev/null || true
        cp "$src_dir/typescript.mdc" .windsurf/rules/ 2>/dev/null || true

        # Convert MDC to markdown for other AI assistants
        sed '1,/^---$/d; /^---$/,$d' "$src_dir/typescript.mdc" > .clinerules/typescript-rules.md 2>/dev/null || true
        sed '1,/^---$/d; /^---$/,$d' "$src_dir/typescript.mdc" > .augment/rules/typescript-rules.md 2>/dev/null || true
        sed '1,/^---$/d; /^---$/,$d' "$src_dir/typescript.mdc" > .roo/rules-code/typescript-rules.md 2>/dev/null || true
    fi

    if [[ -f "$src_dir/shadcn-ui.mdc" ]]; then
        print_color $YELLOW "Adding ShadCN UI component rules..."
        cp "$src_dir/shadcn-ui.mdc" .cursor/rules/ 2>/dev/null || true
        cp "$src_dir/shadcn-ui.mdc" .windsurf/rules/ 2>/dev/null || true

        # Convert MDC to markdown for other AI assistants
        sed '1,/^---$/d; /^---$/,$d' "$src_dir/shadcn-ui.mdc" > .clinerules/shadcn-ui-components.md 2>/dev/null || true
        sed '1,/^---$/d; /^---$/,$d' "$src_dir/shadcn-ui.mdc" > .augment/rules/shadcn-ui-components.md 2>/dev/null || true
        sed '1,/^---$/d; /^---$/,$d' "$src_dir/shadcn-ui.mdc" > .roo/rules-code/shadcn-ui-components.md 2>/dev/null || true
    fi

    if [[ -f "$src_dir/tailwind.mdc" ]]; then
        print_color $YELLOW "Adding Tailwind CSS rules..."
        cp "$src_dir/tailwind.mdc" .cursor/rules/ 2>/dev/null || true
        cp "$src_dir/tailwind.mdc" .windsurf/rules/ 2>/dev/null || true

        # Convert MDC to markdown for other AI assistants
        sed '1,/^---$/d; /^---$/,$d' "$src_dir/tailwind.mdc" > .clinerules/tailwind-css-rules.md 2>/dev/null || true
        sed '1,/^---$/d; /^---$/,$d' "$src_dir/tailwind.mdc" > .augment/rules/tailwind-css-rules.md 2>/dev/null || true
        sed '1,/^---$/d; /^---$/,$d' "$src_dir/tailwind.mdc" > .roo/rules-code/tailwind-css-rules.md 2>/dev/null || true
    fi

    print_color $GREEN "TypeScript/React rules added successfully!"
}

# Function to setup VS Code workspace with MCP configuration
setup_vscode_workspace() {
    print_color $YELLOW "Setting up VS Code workspace configuration..."

    # Create workspace settings directory
    mkdir -p .vscode

    # Create VS Code settings with MCP and AI assistant configuration
    cat > .vscode/settings.json << 'EOF'
{
    "github.copilot.enable": {
        "*": true,
        "yaml": true,
        "plaintext": true,
        "markdown": true
    },
    "github.copilot.chat.codeGeneration.useInstructionFiles": true,
    "github.copilot.chat.reviewSelection.instructions": [
        { "text": "Focus on code quality, security vulnerabilities, and performance issues." },
        { "text": "Provide specific suggestions for improvement with examples." }
    ],
    "github.copilot.chat.commitMessageGeneration.instructions": [
        { "text": "Use conventional commit format (feat:, fix:, docs:, etc.)" },
        { "text": "Keep the first line under 50 characters" },
        { "text": "Include a detailed description if the change is complex" }
    ],
    "chat.promptFiles": true,
    "chat.instructionsFilesLocations": {
        ".github/instructions": true,
        "docs/instructions": true
    },
    "chat.promptFilesLocations": {
        ".github/prompts": true,
        "docs/prompts": true
    },
    "files.associations": {
        "*.mcp": "json",
        "mcp.json": "json"
    },
    "json.schemas": [
        {
            "fileMatch": ["mcp.json", "*.mcp"],
            "url": "https://raw.githubusercontent.com/modelcontextprotocol/specification/main/schema/mcp.schema.json"
        }
    ]
}
EOF

    # Create MCP configuration for AI tools
    cat > .vscode/mcp.json << 'EOF'
{
    "$schema": "https://raw.githubusercontent.com/modelcontextprotocol/specification/main/schema/mcp.schema.json",
    "name": "Project MCP Configuration",
    "version": "1.0.0",
    "description": "Model Context Protocol configuration for AI assistants",
    "tools": [
        {
            "name": "file_reader",
            "description": "Read and analyze project files",
            "parameters": {
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "File path to read"
                    }
                },
                "required": ["path"]
            }
        },
        {
            "name": "code_analyzer",
            "description": "Analyze code structure and patterns",
            "parameters": {
                "type": "object",
                "properties": {
                    "language": {
                        "type": "string",
                        "description": "Programming language"
                    },
                    "file_path": {
                        "type": "string",
                        "description": "Path to code file"
                    }
                },
                "required": ["language", "file_path"]
            }
        },
        {
            "name": "project_structure",
            "description": "Analyze and understand project structure",
            "parameters": {
                "type": "object",
                "properties": {
                    "root_path": {
                        "type": "string",
                        "description": "Project root directory"
                    }
                },
                "required": ["root_path"]
            }
        },
        {
            "name": "documentation_generator",
            "description": "Generate documentation for code and APIs",
            "parameters": {
                "type": "object",
                "properties": {
                    "type": {
                        "type": "string",
                        "enum": ["api", "readme", "inline", "architecture"],
                        "description": "Type of documentation to generate"
                    },
                    "target": {
                        "type": "string",
                        "description": "Target file or component"
                    }
                },
                "required": ["type", "target"]
            }
        },
        {
            "name": "test_generator",
            "description": "Generate unit and integration tests",
            "parameters": {
                "type": "object",
                "properties": {
                    "test_type": {
                        "type": "string",
                        "enum": ["unit", "integration", "e2e"],
                        "description": "Type of test to generate"
                    },
                    "target_file": {
                        "type": "string",
                        "description": "File to generate tests for"
                    },
                    "framework": {
                        "type": "string",
                        "description": "Testing framework to use"
                    }
                },
                "required": ["test_type", "target_file"]
            }
        },
        {
            "name": "code_refactor",
            "description": "Refactor code following best practices",
            "parameters": {
                "type": "object",
                "properties": {
                    "refactor_type": {
                        "type": "string",
                        "enum": ["extract_function", "rename", "optimize", "modernize"],
                        "description": "Type of refactoring to perform"
                    },
                    "target": {
                        "type": "string",
                        "description": "Code section to refactor"
                    }
                },
                "required": ["refactor_type", "target"]
            }
        },
        {
            "name": "security_analyzer",
            "description": "Analyze code for security vulnerabilities",
            "parameters": {
                "type": "object",
                "properties": {
                    "scan_type": {
                        "type": "string",
                        "enum": ["full", "dependencies", "code", "config"],
                        "description": "Type of security scan"
                    },
                    "severity": {
                        "type": "string",
                        "enum": ["low", "medium", "high", "critical"],
                        "description": "Minimum severity level"
                    }
                },
                "required": ["scan_type"]
            }
        }
    ],
    "resources": [
        {
            "name": "project_files",
            "description": "Access to project source files",
            "uri": "file://./src/**/*"
        },
        {
            "name": "documentation",
            "description": "Access to project documentation",
            "uri": "file://./docs/**/*"
        },
        {
            "name": "tests",
            "description": "Access to test files",
            "uri": "file://./tests/**/*"
        },
        {
            "name": "config_files",
            "description": "Access to configuration files",
            "uri": "file://./*.json"
        }
    ],
    "prompts": [
        {
            "name": "code_review",
            "description": "Perform comprehensive code review",
            "arguments": [
                {
                    "name": "file_path",
                    "description": "Path to file for review",
                    "required": true
                }
            ]
        },
        {
            "name": "explain_code",
            "description": "Explain code functionality and patterns",
            "arguments": [
                {
                    "name": "code_section",
                    "description": "Code section to explain",
                    "required": true
                }
            ]
        },
        {
            "name": "generate_tests",
            "description": "Generate comprehensive test suite",
            "arguments": [
                {
                    "name": "target_file",
                    "description": "File to generate tests for",
                    "required": true
                },
                {
                    "name": "test_framework",
                    "description": "Testing framework preference",
                    "required": false
                }
            ]
        },
        {
            "name": "optimize_performance",
            "description": "Analyze and optimize code performance",
            "arguments": [
                {
                    "name": "target",
                    "description": "Code or component to optimize",
                    "required": true
                }
            ]
        }
    ]
}
EOF

    # Create VS Code tasks for common development workflows
    cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "AI: Code Review",
            "type": "shell",
            "command": "echo",
            "args": ["Triggering AI code review..."],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "AI: Generate Tests",
            "type": "shell",
            "command": "echo",
            "args": ["Triggering AI test generation..."],
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "AI: Generate Documentation",
            "type": "shell",
            "command": "echo",
            "args": ["Triggering AI documentation generation..."],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "AI: Security Scan",
            "type": "shell",
            "command": "echo",
            "args": ["Triggering AI security analysis..."],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        }
    ]
}
EOF

    # Create launch configuration for debugging
    cat > .vscode/launch.json << 'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug with AI Assistant",
            "type": "node",
            "request": "launch",
            "program": "${workspaceFolder}/src/index.js",
            "console": "integratedTerminal",
            "env": {
                "NODE_ENV": "development"
            },
            "preLaunchTask": "AI: Code Review"
        }
    ]
}
EOF

    print_color $GREEN "VS Code workspace configured with MCP tools and AI assistant integration!"
}

# Function to ask user for AI coding assistant preference
ask_ai_assistant() {
    print_header "AI Coding Assistant Setup"

    print_color $YELLOW "Which AI coding assistant are you using?"
    echo "1) GitHub Copilot"
    echo "2) Cline (formerly Claude Dev)"
    echo "3) Roo Code"
    echo "4) Cursor"
    echo "5) Augment"
    echo "6) Windsurf"
    echo "7) None / Skip AI setup"
    echo

    while true; do
        read -p "Please enter your choice (1-7): " choice
        case $choice in
            1)
                AI_ASSISTANT="github-copilot"
                break
                ;;
            2)
                AI_ASSISTANT="cline"
                break
                ;;
            3)
                AI_ASSISTANT="roo-code"
                break
                ;;
            4)
                AI_ASSISTANT="cursor"
                break
                ;;
            5)
                AI_ASSISTANT="augment"
                break
                ;;
            6)
                AI_ASSISTANT="windsurf"
                break
                ;;
            7)
                AI_ASSISTANT="none"
                break
                ;;
            *)
                print_color $RED "Invalid choice. Please enter a number between 1-7."
                ;;
        esac
    done

    print_color $GREEN "Selected: $AI_ASSISTANT"
}

# Function to setup GitHub Copilot
setup_github_copilot() {
    print_header "Setting up GitHub Copilot"

    # Install GitHub Copilot extension if VS Code is available
    if command -v code &> /dev/null; then
        print_color "$YELLOW" "Installing GitHub Copilot extension..."
        code --install-extension GitHub.copilot
        code --install-extension GitHub.copilot-chat
    else
        print_color "$YELLOW" "VS Code not found. Extensions will need to be installed manually."
    fi

    # Consolidated directory creation
    print_color "$YELLOW" "Creating GitHub Copilot directory structure..."
    safe_mkdir \
        .github \
        .github/instructions \
        .github/prompts

    # Create workspace settings directory
    setup_vscode_workspace

    # Copy TypeScript/React rules
    copy_typescript_react_rules

    # Create GitHub Copilot instructions using utility functions
    print_color "$YELLOW" "Creating GitHub Copilot instructions..."

    create_rule_file ".github/copilot-instructions.md" '# Project Coding Standards

## General Guidelines
- Write clean, readable, and maintainable code
- Follow the existing code style and patterns in the project
- Add meaningful comments for complex logic
- Use descriptive variable and function names
- Prefer composition over inheritance
- Write tests for new functionality

## Code Quality
- Handle errors gracefully with proper error messages
- Validate input parameters
- Use appropriate data structures for the task
- Optimize for readability first, performance second
- Follow SOLID principles where applicable

## Documentation
- Update README.md when adding new features
- Document public APIs and complex functions
- Include usage examples in documentation
- Keep documentation up to date with code changes

## Security
- Sanitize user inputs
- Use secure coding practices
- Avoid hardcoding sensitive information
- Follow principle of least privilege
- Validate and escape data appropriately

## Testing
- Write unit tests for new functions
- Include edge cases in tests
- Use descriptive test names
- Mock external dependencies
- Aim for good test coverage'

    create_rule_file ".github/instructions/typescript.instructions.md" '---
applyTo: "**/*.ts,**/*.tsx"
description: "TypeScript and React coding guidelines"
---

# TypeScript and React Guidelines

## TypeScript Best Practices
- Use strict TypeScript configuration
- Prefer interfaces over types for object shapes
- Use union types for controlled values
- Implement proper error handling with Result types
- Use generic types for reusable components
- Prefer readonly arrays and objects when possible

## React Guidelines
- Use functional components with hooks
- Follow React hooks rules (no conditional hooks)
- Use React.FC type for components with children
- Keep components small and focused (single responsibility)
- Use proper key props for lists
- Implement proper error boundaries
- Use CSS modules or styled-components for styling

## Naming Conventions
- Use PascalCase for component names and interfaces
- Use camelCase for variables, functions, and methods
- Use UPPER_SNAKE_CASE for constants
- Prefix custom hooks with 'use'
- Use descriptive names that explain purpose'

    cat > .github/instructions/python.instructions.md << 'EOF'
---
applyTo: "**/*.py"
description: "Python coding guidelines"
---

# Python Guidelines

## Code Style
- Follow PEP 8 style guide
- Use type hints for function parameters and return values
- Use docstrings for modules, classes, and functions
- Prefer list comprehensions over loops when readable
- Use f-strings for string formatting
- Keep line length under 88 characters (Black formatter)

## Best Practices
- Use virtual environments for dependencies
- Handle exceptions specifically, avoid bare except
- Use context managers (with statements) for resource management
- Prefer pathlib over os.path for file operations
- Use dataclasses or Pydantic models for structured data
- Follow the principle of least surprise

## Testing
- Use pytest for testing
- Write descriptive test function names
- Use fixtures for test setup
- Mock external dependencies
- Test edge cases and error conditions
EOF

    # Create prompts directory and sample files
    mkdir -p .github/prompts

    cat > .github/prompts/code-review.prompt.md << 'EOF'
---
mode: 'ask'
description: 'Perform a comprehensive code review'
---

Please perform a comprehensive code review of the selected code. Focus on:

## Code Quality
- Code readability and maintainability
- Adherence to coding standards and best practices
- Proper error handling and edge cases
- Performance considerations

## Security
- Input validation and sanitization
- Potential security vulnerabilities
- Proper authentication and authorization
- Data protection and privacy concerns

## Architecture
- Code organization and structure
- Separation of concerns
- Dependency management
- Scalability considerations

## Testing
- Test coverage and quality
- Missing test cases
- Test maintainability

Please provide specific, actionable feedback with examples where possible.
EOF

    cat > .github/prompts/generate-tests.prompt.md << 'EOF'
---
mode: 'agent'
tools: ['codebase']
description: 'Generate comprehensive unit tests'
---

Generate comprehensive unit tests for the selected code. Include:

## Test Coverage
- Happy path scenarios
- Edge cases and boundary conditions
- Error conditions and exception handling
- Input validation tests

## Test Structure
- Use descriptive test names that explain what is being tested
- Follow AAA pattern (Arrange, Act, Assert)
- Use appropriate test fixtures and mocks
- Group related tests in test classes or describe blocks

## Test Quality
- Make tests independent and isolated
- Use meaningful assertions
- Test one thing at a time
- Include both positive and negative test cases

Please generate tests using the appropriate testing framework for the language.
EOF

    print_color $GREEN "GitHub Copilot setup completed!"
    print_color $YELLOW "Created GitHub Copilot configuration:"
    echo "  ✓ .github/ - Copilot instructions and prompts"
    echo "  ✓ .vscode/ - VS Code workspace with MCP configuration"
    echo "  ✓ Instructions files for TypeScript and Python"
    echo "  ✓ Prompt files for code review and test generation"
    echo "  ✓ TypeScript/React rules (TypeScript, ShadCN UI, Tailwind CSS)"
    echo
    print_color $YELLOW "Next steps:"
    echo "1. Restart VS Code to apply settings"
    echo "2. Sign in to GitHub Copilot (Ctrl+Shift+P -> 'GitHub Copilot: Sign In')"
    echo "3. Review and customize the generated instructions in .github/copilot-instructions.md"
    echo "4. Explore the prompt files in .github/prompts/"
}

# Function to setup Cline
setup_cline() {
    print_header "Setting up Cline (Claude Dev)"

    # Install Cline extension if VS Code is available
    if command -v code &> /dev/null; then
        print_color $YELLOW "Installing Cline extension..."
        code --install-extension saoudrizwan.claude-dev
    else
        print_color $YELLOW "VS Code not found. Extension will need to be installed manually."
    fi

    # Create VS Code workspace
    setup_vscode_workspace

    # Copy TypeScript/React rules
    copy_typescript_react_rules

    # Consolidated directory creation
    print_color "$YELLOW" "Creating Cline directory structure..."
    safe_mkdir \
        .clinerules \
        clinerules-bank/clients \
        clinerules-bank/frameworks \
        clinerules-bank/project-types \
        clinerules-bank/contexts

    # Create main coding standards rule
    cat > .clinerules/01-coding-standards.md << 'EOF'
# Coding Standards

## General Guidelines
- Write clean, readable, and maintainable code
- Follow the existing code style and patterns in the project
- Use descriptive variable and function names
- Add meaningful comments for complex logic
- Prefer composition over inheritance
- Handle errors gracefully with proper error messages

## Code Quality
- Validate input parameters
- Use appropriate data structures for the task
- Optimize for readability first, performance second
- Follow SOLID principles where applicable
- Write tests for new functionality

## Documentation Requirements
- Update relevant documentation when modifying features
- Keep README.md in sync with new capabilities
- Document public APIs and complex functions
- Include usage examples in documentation

## Security Best Practices
- Sanitize user inputs
- Avoid hardcoding sensitive information
- Follow principle of least privilege
- Validate and escape data appropriately
- Use secure coding practices
EOF

    # Create documentation rule
    cat > .clinerules/02-documentation.md << 'EOF'
# Documentation Requirements

## Code Documentation
- Document all public APIs and interfaces
- Include JSDoc/docstrings for functions and classes
- Explain complex algorithms and business logic
- Keep comments up to date with code changes

## Project Documentation
- Update README.md when adding new features
- Maintain changelog entries in CHANGELOG.md
- Document setup and installation procedures
- Include troubleshooting guides

## Architecture Decision Records
Create ADRs in /docs/adr for:
- Major dependency changes
- Architectural pattern changes
- New integration patterns
- Database schema changes
- Follow template in /docs/adr/template.md (if exists)

## API Documentation
- Use OpenAPI/Swagger for REST APIs
- Document request/response schemas
- Include example requests and responses
- Document error codes and messages
EOF

    # Create testing standards rule
    cat > .clinerules/03-testing-standards.md << 'EOF'
# Testing Standards

## Test Requirements
- Unit tests required for business logic
- Integration tests for API endpoints
- E2E tests for critical user flows
- Test coverage should be meaningful, not just high percentage

## Test Structure
- Use descriptive test names that explain what is being tested
- Follow AAA pattern (Arrange, Act, Assert)
- Use appropriate test fixtures and mocks
- Group related tests in test classes or describe blocks

## Test Quality
- Make tests independent and isolated
- Use meaningful assertions
- Test one thing at a time
- Include both positive and negative test cases
- Test edge cases and boundary conditions

## Test Organization
- Place tests near the code they test
- Use consistent naming conventions
- Mock external dependencies
- Keep test data separate from test logic
EOF

    # Create rules bank examples

    # TypeScript/React rules
    cat > clinerules-bank/frameworks/typescript-react.md << 'EOF'
# TypeScript and React Guidelines

## TypeScript Best Practices
- Use strict TypeScript configuration
- Prefer interfaces over types for object shapes
- Use union types for controlled values
- Implement proper error handling with Result types
- Use generic types for reusable components
- Prefer readonly arrays and objects when possible

## React Guidelines
- Use functional components with hooks
- Follow React hooks rules (no conditional hooks)
- Use React.FC type for components with children
- Keep components small and focused (single responsibility)
- Use proper key props for lists
- Implement proper error boundaries
- Use CSS modules or styled-components for styling

## Naming Conventions
- Use PascalCase for component names and interfaces
- Use camelCase for variables, functions, and methods
- Use UPPER_SNAKE_CASE for constants
- Prefix custom hooks with 'use'
- Use descriptive names that explain purpose
EOF

    # Python rules
    cat > clinerules-bank/frameworks/python.md << 'EOF'
# Python Guidelines

## Code Style
- Follow PEP 8 style guide
- Use type hints for function parameters and return values
- Use docstrings for modules, classes, and functions
- Prefer list comprehensions over loops when readable
- Use f-strings for string formatting
- Keep line length under 88 characters (Black formatter)

## Best Practices
- Use virtual environments for dependencies
- Handle exceptions specifically, avoid bare except
- Use context managers (with statements) for resource management
- Prefer pathlib over os.path for file operations
- Use dataclasses or Pydantic models for structured data
- Follow the principle of least surprise

## Testing with pytest
- Use pytest for testing
- Write descriptive test function names
- Use fixtures for test setup
- Mock external dependencies
- Test edge cases and error conditions
EOF

    # API service rules
    cat > clinerules-bank/project-types/api-service.md << 'EOF'
# API Service Guidelines

## API Design
- Follow RESTful principles
- Use consistent URL patterns
- Implement proper HTTP status codes
- Version your APIs (e.g., /api/v1/)
- Use JSON for request/response bodies

## Error Handling
- Return consistent error response format
- Include error codes and descriptive messages
- Log errors with appropriate detail
- Implement proper exception handling
- Use middleware for common error scenarios

## Security
- Implement authentication and authorization
- Validate all input data
- Use HTTPS in production
- Implement rate limiting
- Sanitize user inputs

## Performance
- Implement caching where appropriate
- Use database indexing effectively
- Implement pagination for large datasets
- Monitor API performance metrics
- Use connection pooling
EOF

    # Frontend app rules
    cat > clinerules-bank/project-types/frontend-app.md << 'EOF'
# Frontend Application Guidelines

## Component Architecture
- Use component-based architecture
- Keep components small and focused
- Implement proper state management
- Use props for component communication
- Implement proper error boundaries

## State Management
- Use local state for component-specific data
- Use global state for shared application data
- Implement proper data flow patterns
- Avoid prop drilling with context or state management
- Keep state minimal and normalized

## Performance
- Implement code splitting and lazy loading
- Optimize bundle size
- Use proper caching strategies
- Implement virtual scrolling for large lists
- Optimize images and assets

## User Experience
- Implement proper loading states
- Provide meaningful error messages
- Ensure accessibility compliance
- Implement responsive design
- Test across different browsers and devices
EOF

    # Create a sample client-specific rule
    cat > clinerules-bank/clients/example-client.md << 'EOF'
# Example Client Specific Rules

## Client Requirements
- Follow client's specific coding standards
- Use client-approved libraries and frameworks
- Implement client-specific security requirements
- Follow client's deployment procedures

## Communication
- Use client's preferred documentation format
- Follow client's code review process
- Use client's project management tools
- Maintain client-specific changelog format

## Compliance
- Follow client's regulatory requirements
- Implement client-specific audit trails
- Use client-approved data handling procedures
- Follow client's backup and recovery procedures
EOF

    # Create context-specific rules
    cat > clinerules-bank/contexts/debugging.md << 'EOF'
# Debugging Context Rules

## Debugging Approach
- Reproduce the issue consistently
- Use systematic debugging techniques
- Add logging at key points
- Use debugger tools effectively
- Document findings and solutions

## Code Analysis
- Review recent changes that might cause issues
- Check for common patterns that cause bugs
- Verify input validation and error handling
- Review dependencies and their versions
- Check configuration and environment variables

## Testing During Debug
- Create minimal test cases to reproduce issues
- Test edge cases and boundary conditions
- Verify fixes don't break existing functionality
- Add regression tests for fixed bugs
- Test in different environments
EOF

    cat > clinerules-bank/contexts/refactoring.md << 'EOF'
# Refactoring Context Rules

## Refactoring Principles
- Make small, incremental changes
- Maintain existing functionality
- Improve code readability and maintainability
- Remove code duplication
- Simplify complex logic

## Safety Measures
- Ensure comprehensive test coverage before refactoring
- Run tests after each refactoring step
- Use version control to track changes
- Review changes carefully before committing
- Consider impact on other parts of the system

## Code Quality Improvements
- Extract methods and functions for better organization
- Rename variables and functions for clarity
- Remove dead code and unused imports
- Improve error handling and logging
- Update documentation to reflect changes
EOF

    # Create README for rules management
    cat > clinerules-bank/README.md << 'EOF'
# Cline Rules Bank

This directory contains a collection of rule files that can be activated in the `.clinerules/` folder as needed.

## Structure

- `clients/` - Client-specific rule sets
- `frameworks/` - Framework and language-specific rules
- `project-types/` - Rules for different types of projects
- `contexts/` - Context-specific rules (debugging, refactoring, etc.)

## Usage

To activate rules, copy them from this bank to the `.clinerules/` folder:

```bash
# Activate TypeScript/React rules
cp clinerules-bank/frameworks/typescript-react.md .clinerules/

# Activate API service rules
cp clinerules-bank/project-types/api-service.md .clinerules/

# Activate debugging context
cp clinerules-bank/contexts/debugging.md .clinerules/
```

## Managing Active Rules

Active rules in `.clinerules/` are automatically applied by Cline. You can:

1. Use the Cline UI to toggle rules on/off
2. Manually copy/remove files from `.clinerules/`
3. Use the `/newrule` command in Cline to create new rules

## Best Practices

- Keep individual rule files focused on specific concerns
- Use descriptive filenames
- Test rules to ensure they work as expected
- Update rules based on project evolution
- Share useful rules with your team
EOF

    # Create VS Code workspace
    setup_vscode_workspace

    # Copy TypeScript/React rules
    copy_typescript_react_rules

    print_color $GREEN "Cline setup completed!"
    print_color $YELLOW "Created Cline rules structure:"
    echo "  ✓ .clinerules/ - Active rules folder"
    echo "  ✓ clinerules-bank/ - Rules repository"
    echo "  ✓ .vscode/ - VS Code workspace with MCP configuration"
    echo "  ✓ Default coding standards, documentation, and testing rules"
    echo "  ✓ Framework-specific rules (TypeScript/React, Python)"
    echo "  ✓ Project type rules (API service, Frontend app)"
    echo "  ✓ Context-specific rules (Debugging, Refactoring)"
    echo "  ✓ TypeScript/React rules (TypeScript, ShadCN UI, Tailwind CSS)"
    echo
    print_color $YELLOW "Next steps:"
    echo "1. Get your Claude API key from Anthropic Console"
    echo "2. Open Cline in VS Code (Ctrl+Shift+P -> 'Cline: Open')"
    echo "3. Configure your API key in Cline settings"
    echo "4. Review and customize rules in .clinerules/ folder"
    echo "5. Activate additional rules from clinerules-bank/ as needed"
    echo "6. Use the Cline UI to toggle rules on/off during conversations"
}

# Function to setup Cursor
setup_cursor() {
    print_header "Setting up Cursor"

    # Check if Cursor is installed (optional)
    if ! command -v cursor &> /dev/null; then
        print_color $YELLOW "Cursor not found. Rules will be created for when you install Cursor."
    else
        print_color $GREEN "Cursor detected. Setting up rules and configuration."
    fi

    # Create Cursor rules structure
    print_color $YELLOW "Creating Cursor rules structure..."
    mkdir -p .cursor/rules
    mkdir -p cursor-rules-bank/{frameworks,project-types,workflows,standards}

    # Create always-applied coding standards rule
    cat > .cursor/rules/coding-standards.mdc << 'EOF'
---
description: Core coding standards and best practices
globs: []
alwaysApply: true
---

# Core Coding Standards

## General Guidelines
- Write clean, readable, and maintainable code
- Follow existing code style and patterns in the project
- Use descriptive variable and function names
- Add meaningful comments for complex logic
- Prefer composition over inheritance
- Handle errors gracefully with proper error messages

## Code Quality
- Validate input parameters and handle edge cases
- Use appropriate data structures for the task
- Optimize for readability first, performance second
- Follow SOLID principles where applicable
- Write tests for new functionality

## Security Best Practices
- Sanitize user inputs and validate data
- Avoid hardcoding sensitive information
- Follow principle of least privilege
- Use secure coding practices
- Implement proper authentication and authorization

## Documentation
- Update relevant documentation when modifying features
- Keep README.md in sync with new capabilities
- Document public APIs and complex functions
- Include usage examples in documentation
EOF

    # Create auto-attached TypeScript/React rule
    cat > .cursor/rules/typescript-react.mdc << 'EOF'
---
description: TypeScript and React development guidelines
globs: ["**/*.ts", "**/*.tsx", "**/*.jsx"]
alwaysApply: false
---

# TypeScript and React Guidelines

## TypeScript Best Practices
- Use strict TypeScript configuration
- Prefer interfaces over types for object shapes
- Use union types for controlled values
- Implement proper error handling with Result types
- Use generic types for reusable components
- Prefer readonly arrays and objects when possible

## React Guidelines
- Use functional components with hooks
- Follow React hooks rules (no conditional hooks)
- Use React.FC type for components with children
- Keep components small and focused (single responsibility)
- Use proper key props for lists
- Implement proper error boundaries
- Use CSS modules or styled-components for styling

## Naming Conventions
- Use PascalCase for component names and interfaces
- Use camelCase for variables, functions, and methods
- Use UPPER_SNAKE_CASE for constants
- Prefix custom hooks with 'use'
- Use descriptive names that explain purpose

@component-template.tsx
EOF

    # Create component template
    cat > .cursor/rules/component-template.tsx << 'EOF'
import React from 'react';

interface ComponentNameProps {
  // Define props here
  children?: React.ReactNode;
}

export const ComponentName: React.FC<ComponentNameProps> = ({
  children
}) => {
  // Component logic here

  return (
    <div className="component-name">
      {children}
    </div>
  );
};

export default ComponentName;
EOF

    # Create auto-attached API rule
    cat > .cursor/rules/api-development.mdc << 'EOF'
---
description: API development standards and patterns
globs: ["**/api/**", "**/routes/**", "**/controllers/**", "**/*.api.ts"]
alwaysApply: false
---

# API Development Guidelines

## RESTful API Design
- Follow RESTful principles and conventions
- Use consistent URL patterns and naming
- Implement proper HTTP status codes
- Version your APIs (e.g., /api/v1/)
- Use JSON for request/response bodies

## Error Handling
- Return consistent error response format
- Include error codes and descriptive messages
- Log errors with appropriate detail
- Implement proper exception handling
- Use middleware for common error scenarios

## Validation and Security
- Use zod for all input validation
- Define return types with zod schemas
- Export types generated from schemas
- Implement authentication and authorization
- Sanitize user inputs and validate data

## Performance
- Implement caching where appropriate
- Use database indexing effectively
- Implement pagination for large datasets
- Monitor API performance metrics
- Use connection pooling

@api-template.ts
EOF

    # Create API template
    cat > .cursor/rules/api-template.ts << 'EOF'
import { z } from 'zod';
import { Request, Response, NextFunction } from 'express';

// Request validation schema
const RequestSchema = z.object({
  // Define request schema here
});

// Response schema
const ResponseSchema = z.object({
  // Define response schema here
});

// Types
export type RequestType = z.infer<typeof RequestSchema>;
export type ResponseType = z.infer<typeof ResponseSchema>;

// Controller function
export const controllerFunction = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    // Validate request
    const validatedData = RequestSchema.parse(req.body);

    // Business logic here

    // Return response
    const response: ResponseType = {
      // Response data
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};
EOF

    # Create manual testing rule
    cat > .cursor/rules/testing-standards.mdc << 'EOF'
---
description: Testing standards and best practices
globs: []
alwaysApply: false
---

# Testing Standards

## Test Requirements
- Unit tests required for business logic
- Integration tests for API endpoints
- E2E tests for critical user flows
- Test coverage should be meaningful, not just high percentage

## Test Structure
- Use descriptive test names that explain what is being tested
- Follow AAA pattern (Arrange, Act, Assert)
- Use appropriate test fixtures and mocks
- Group related tests in test classes or describe blocks

## Test Quality
- Make tests independent and isolated
- Use meaningful assertions
- Test one thing at a time
- Include both positive and negative test cases
- Test edge cases and boundary conditions

## Test Organization
- Place tests near the code they test
- Use consistent naming conventions
- Mock external dependencies
- Keep test data separate from test logic

@test-template.test.ts
EOF

    # Create test template
    cat > .cursor/rules/test-template.test.ts << 'EOF'
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
// or import from your testing framework

describe('ComponentName', () => {
  beforeEach(() => {
    // Setup before each test
  });

  afterEach(() => {
    // Cleanup after each test
  });

  describe('when condition', () => {
    it('should do something specific', () => {
      // Arrange
      const input = 'test input';

      // Act
      const result = functionUnderTest(input);

      // Assert
      expect(result).toBe('expected output');
    });

    it('should handle edge case', () => {
      // Test edge cases
    });
  });

  describe('error handling', () => {
    it('should throw error for invalid input', () => {
      expect(() => {
        functionUnderTest(null);
      }).toThrow('Expected error message');
    });
  });
});
EOF

    # Create agent-requested documentation rule
    cat > .cursor/rules/documentation-generator.mdc << 'EOF'
---
description: Generate comprehensive documentation for code and APIs
globs: []
alwaysApply: false
---

# Documentation Generation Guidelines

When asked to generate documentation:

## Code Documentation
- Extract and analyze existing code comments
- Generate JSDoc/TSDoc for functions and classes
- Document parameters, return types, and exceptions
- Include usage examples for public APIs

## API Documentation
- Generate OpenAPI/Swagger specifications
- Document all endpoints with request/response schemas
- Include example requests and responses
- Document error codes and messages

## README Generation
- Analyze project structure and dependencies
- Generate installation and setup instructions
- Include usage examples and common workflows
- Document configuration options and environment variables

## Architecture Documentation
- Create high-level system diagrams
- Document component relationships
- Explain data flow and business logic
- Include deployment and scaling considerations

## Process
1. Analyze existing code and comments
2. Extract key functionality and patterns
3. Generate markdown documentation
4. Include practical examples
5. Ensure documentation is up-to-date with code
EOF

    # Create rules bank examples

    # Python framework rules
    cat > cursor-rules-bank/frameworks/python-django.mdc << 'EOF'
---
description: Django development guidelines and best practices
globs: ["**/*.py", "**/models.py", "**/views.py", "**/serializers.py"]
alwaysApply: false
---

# Django Development Guidelines

## Model Best Practices
- Use descriptive model names in singular form
- Add __str__ methods to all models
- Use proper field types and constraints
- Implement custom managers when needed
- Add model validation in clean() methods

## View Guidelines
- Use class-based views for complex logic
- Keep views thin, move logic to services
- Use proper HTTP status codes
- Implement proper error handling
- Use Django's built-in authentication

## API Development
- Use Django REST Framework for APIs
- Implement proper serializers with validation
- Use viewsets for CRUD operations
- Implement proper pagination
- Add API documentation with drf-spectacular

## Security
- Always use Django's CSRF protection
- Validate and sanitize user inputs
- Use Django's built-in authentication
- Implement proper permissions
- Keep SECRET_KEY secure

@django-model-template.py
@django-view-template.py
EOF

    # Create Django templates
    cat > cursor-rules-bank/frameworks/django-model-template.py << 'EOF'
from django.db import models
from django.core.validators import MinLengthValidator

class ModelName(models.Model):
    """
    Model description here.
    """

    # Fields
    name = models.CharField(
        max_length=255,
        validators=[MinLengthValidator(2)],
        help_text="Model name"
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Model Name"
        verbose_name_plural = "Model Names"
        ordering = ['-created_at']

    def __str__(self):
        return self.name

    def clean(self):
        """Custom validation logic."""
        super().clean()
        # Add custom validation here
EOF

    # Next.js project type rules
    cat > cursor-rules-bank/project-types/nextjs-app.mdc << 'EOF'
---
description: Next.js application development guidelines
globs: ["**/app/**", "**/pages/**", "**/*.page.tsx", "**/layout.tsx"]
alwaysApply: false
---

# Next.js Application Guidelines

## App Router (Next.js 13+)
- Use app directory structure
- Implement proper loading and error boundaries
- Use server components by default
- Add 'use client' only when necessary
- Implement proper metadata for SEO

## Performance Optimization
- Use Next.js Image component for images
- Implement proper code splitting
- Use dynamic imports for heavy components
- Optimize bundle size with proper imports
- Implement proper caching strategies

## Routing and Navigation
- Use Next.js Link component for navigation
- Implement proper route groups
- Use parallel routes for complex layouts
- Implement proper error handling
- Use middleware for authentication

## Data Fetching
- Use server components for data fetching
- Implement proper loading states
- Use React Query for client-side data
- Implement proper error boundaries
- Cache data appropriately

@nextjs-page-template.tsx
@nextjs-layout-template.tsx
EOF

    # Workflow rules
    cat > cursor-rules-bank/workflows/code-review.mdc << 'EOF'
---
description: Automated code review workflow and checklist
globs: []
alwaysApply: false
---

# Code Review Workflow

When performing code reviews:

## Automated Analysis Steps
1. Run linting and formatting checks
2. Execute test suite and check coverage
3. Analyze code complexity and maintainability
4. Check for security vulnerabilities
5. Verify documentation is up-to-date

## Review Checklist
- Code follows project standards and conventions
- Functions and classes have appropriate size and complexity
- Error handling is implemented properly
- Tests cover new functionality and edge cases
- Documentation is clear and up-to-date
- No hardcoded secrets or sensitive information
- Performance implications are considered
- Security best practices are followed

## Feedback Guidelines
- Provide specific, actionable feedback
- Include code examples for suggestions
- Explain the reasoning behind recommendations
- Prioritize feedback (critical, important, nice-to-have)
- Be constructive and respectful

## Common Issues to Check
- Memory leaks and resource management
- SQL injection and XSS vulnerabilities
- Race conditions and concurrency issues
- Proper input validation and sanitization
- Consistent error handling patterns
EOF

    # Create README for rules management
    cat > cursor-rules-bank/README.md << 'EOF'
# Cursor Rules Bank

This directory contains a collection of rule files that can be activated in the `.cursor/rules/` folder as needed.

## Structure

- `frameworks/` - Framework and language-specific rules
- `project-types/` - Rules for different types of projects
- `workflows/` - Workflow and process-specific rules
- `standards/` - Coding standards and conventions

## Rule Types

Cursor supports different rule types:

- **Always Applied** (`alwaysApply: true`) - Always included in context
- **Auto Attached** (`globs: [...]`) - Applied when matching files are referenced
- **Agent Requested** (`description: "..."`) - AI decides when to include
- **Manual** - Only when explicitly mentioned with `@ruleName`

## Usage

To activate rules, copy them from this bank to the `.cursor/rules/` folder:

```bash
# Activate Python/Django rules
cp cursor-rules-bank/frameworks/python-django.mdc .cursor/rules/

# Activate Next.js project rules
cp cursor-rules-bank/project-types/nextjs-app.mdc .cursor/rules/

# Activate code review workflow
cp cursor-rules-bank/workflows/code-review.mdc .cursor/rules/
```

## Managing Rules

You can manage rules through:

1. Cursor Settings → Rules (view all rules and their status)
2. Use `/Generate Cursor Rules` command in chat
3. Create new rules with "New Cursor Rule" command
4. Reference files in rules using `@filename.ext`

## Best Practices

- Keep rules under 500 lines
- Split large rules into multiple, composable rules
- Provide concrete examples or referenced files
- Avoid vague guidance - write rules like clear internal docs
- Use appropriate rule types for different scenarios
EOF

    # Create VS Code workspace
    setup_vscode_workspace

    # Copy TypeScript/React rules
    copy_typescript_react_rules

    print_color $GREEN "Cursor setup completed!"
    print_color $YELLOW "Created Cursor rules structure:"
    echo "  ✓ .cursor/rules/ - Project rules folder"
    echo "  ✓ cursor-rules-bank/ - Rules repository"
    echo "  ✓ .vscode/ - VS Code workspace with MCP configuration"
    echo "  ✓ Always-applied coding standards"
    echo "  ✓ Auto-attached TypeScript/React and API rules"
    echo "  ✓ Manual testing and documentation rules"
    echo "  ✓ Framework-specific rules (Python/Django, Next.js)"
    echo "  ✓ Workflow rules (code review)"
    echo "  ✓ Template files for components, APIs, and tests"
    echo "  ✓ TypeScript/React rules (TypeScript, ShadCN UI, Tailwind CSS)"
    echo
    print_color $YELLOW "Next steps:"
    echo "1. Install Cursor from https://cursor.com if not already installed"
    echo "2. Open your project in Cursor"
    echo "3. Go to Cursor Settings → Rules to view and manage rules"
    echo "4. Activate additional rules from cursor-rules-bank/ as needed"
    echo "5. Use '/Generate Cursor Rules' command to create custom rules"
    echo "6. Reference template files in rules using @filename.ext"
}

# Function to setup Windsurf
setup_windsurf() {
    print_header "Setting up Windsurf"

    # Check if Windsurf is installed (optional)
    if ! command -v windsurf &> /dev/null; then
        print_color $YELLOW "Windsurf not found. Rules will be created for when you install Windsurf."
    else
        print_color $GREEN "Windsurf detected. Setting up rules and configuration."
    fi

    # Consolidated directory creation
    print_color $YELLOW "Creating Windsurf directory structure..."
    safe_mkdir \
        .windsurf/rules \
        windsurf-rules-bank/frameworks \
        windsurf-rules-bank/project-types \
        windsurf-rules-bank/workflows \
        windsurf-rules-bank/standards \
        windsurf-rules-bank/contexts

    # Create global rules template with automatic placement
    print_color $YELLOW "Creating global rules template..."
# Global Windsurf Rules

## Communication Style
- Provide clear, concise explanations
- Use bullet points and numbered lists for clarity
- Include practical examples when explaining concepts
- Ask clarifying questions when requirements are ambiguous

## Code Quality Standards
- Write clean, readable, and maintainable code
- Use descriptive variable and function names
- Add meaningful comments for complex logic
- Follow established patterns in the codebase
- Prefer composition over inheritance

## Documentation Requirements
- Update documentation when making changes
- Include usage examples for new features
- Keep README files current and accurate
- Document API endpoints and parameters

## Security Best Practices
- Validate and sanitize all user inputs
- Use secure coding practices
- Avoid hardcoding sensitive information
- Implement proper error handling
- Follow principle of least privilege'

    # Automatically place global rules in user's Windsurf directory
    local windsurf_global_dir="$HOME/.windsurf"
    local windsurf_global_path="$windsurf_global_dir/global_rules.md"
    place_global_rules "Windsurf" "$global_rules_content" "$windsurf_global_path"

    # Create always-on coding standards rule
    cat > .windsurf/rules/coding-standards.md << 'EOF'
# Coding Standards

**Activation Mode:** Always On

## General Guidelines
- Write clean, readable, and maintainable code
- Follow existing code style and patterns in the project
- Use descriptive variable and function names
- Add meaningful comments for complex logic
- Prefer composition over inheritance
- Handle errors gracefully with proper error messages

## Code Quality
- Validate input parameters and handle edge cases
- Use appropriate data structures for the task
- Optimize for readability first, performance second
- Follow SOLID principles where applicable
- Write tests for new functionality

## Security Best Practices
- Sanitize user inputs and validate data
- Avoid hardcoding sensitive information
- Follow principle of least privilege
- Use secure coding practices
- Implement proper authentication and authorization

## Documentation
- Update relevant documentation when modifying features
- Keep README.md in sync with new capabilities
- Document public APIs and complex functions
- Include usage examples in documentation
EOF

    # Create glob-based TypeScript/React rule
    cat > .windsurf/rules/typescript-react.md << 'EOF'
# TypeScript and React Guidelines

**Activation Mode:** Glob Pattern: `**/*.ts,**/*.tsx,**/*.jsx`

<coding_guidelines>
- Use TypeScript for all new code
- Follow functional programming principles where possible
- Use interfaces for data structures and type definitions
- Prefer immutable data (const, readonly)
- Use optional chaining (?.) and nullish coalescing (??) operators
</coding_guidelines>

<react_guidelines>
- Use functional components with hooks
- Follow React hooks rules (no conditional hooks)
- Use React.FC type for components with children
- Keep components small and focused (single responsibility)
- Use proper key props for lists
- Implement proper error boundaries
- Use CSS modules or styled-components for styling
</react_guidelines>

<naming_conventions>
- Use PascalCase for component names and interfaces
- Use camelCase for variables, functions, and methods
- Use UPPER_SNAKE_CASE for constants
- Prefix custom hooks with 'use'
- Use descriptive names that explain purpose
</naming_conventions>

## Component Template
```tsx
import React from 'react';

interface ComponentNameProps {
  // Define props here
  children?: React.ReactNode;
}

export const ComponentName: React.FC<ComponentNameProps> = ({
  children
}) => {
  // Component logic here

  return (
    <div className="component-name">
      {children}
    </div>
  );
};

export default ComponentName;
```
EOF

    # Create model-decision API development rule
    cat > .windsurf/rules/api-development.md << 'EOF'
# API Development Guidelines

**Activation Mode:** Model Decision
**Description:** Apply when working with REST APIs, backend services, or API endpoints

<api_design>
- Follow RESTful principles and conventions
- Use consistent URL patterns and naming
- Implement proper HTTP status codes
- Version your APIs (e.g., /api/v1/)
- Use JSON for request/response bodies
</api_design>

<error_handling>
- Return consistent error response format
- Include error codes and descriptive messages
- Log errors with appropriate detail
- Implement proper exception handling
- Use middleware for common error scenarios
</error_handling>

<validation_security>
- Use schema validation for all inputs (e.g., Zod, Joi)
- Define return types with validation schemas
- Export types generated from schemas
- Implement authentication and authorization
- Sanitize user inputs and validate data
</validation_security>

<performance>
- Implement caching where appropriate
- Use database indexing effectively
- Implement pagination for large datasets
- Monitor API performance metrics
- Use connection pooling
</performance>

## API Endpoint Template
```typescript
import { z } from 'zod';
import { Request, Response, NextFunction } from 'express';

// Request validation schema
const RequestSchema = z.object({
  // Define request schema here
});

// Response schema
const ResponseSchema = z.object({
  // Define response schema here
});

// Types
export type RequestType = z.infer<typeof RequestSchema>;
export type ResponseType = z.infer<typeof ResponseSchema>;

// Controller function
export const controllerFunction = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    // Validate request
    const validatedData = RequestSchema.parse(req.body);

    // Business logic here

    // Return response
    const response: ResponseType = {
      // Response data
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};
```
EOF

    # Create manual testing rule
    cat > .windsurf/rules/testing-standards.md << 'EOF'
# Testing Standards

**Activation Mode:** Manual (use @testing-standards to activate)

<test_requirements>
- Unit tests required for business logic
- Integration tests for API endpoints
- E2E tests for critical user flows
- Test coverage should be meaningful, not just high percentage
</test_requirements>

<test_structure>
- Use descriptive test names that explain what is being tested
- Follow AAA pattern (Arrange, Act, Assert)
- Use appropriate test fixtures and mocks
- Group related tests in test classes or describe blocks
</test_structure>

<test_quality>
- Make tests independent and isolated
- Use meaningful assertions
- Test one thing at a time
- Include both positive and negative test cases
- Test edge cases and boundary conditions
</test_quality>

<test_organization>
- Place tests near the code they test
- Use consistent naming conventions
- Mock external dependencies
- Keep test data separate from test logic
</test_organization>

## Test Template
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('ComponentName', () => {
  beforeEach(() => {
    // Setup before each test
  });

  afterEach(() => {
    // Cleanup after each test
  });

  describe('when condition', () => {
    it('should do something specific', () => {
      // Arrange
      const input = 'test input';

      // Act
      const result = functionUnderTest(input);

      // Assert
      expect(result).toBe('expected output');
    });

    it('should handle edge case', () => {
      // Test edge cases
    });
  });

  describe('error handling', () => {
    it('should throw error for invalid input', () => {
      expect(() => {
        functionUnderTest(null);
      }).toThrow('Expected error message');
    });
  });
});
```
EOF

    # Create rules bank examples

    # Python/Django framework rules
    cat > windsurf-rules-bank/frameworks/python-django.md << 'EOF'
# Python and Django Guidelines

**Activation Mode:** Glob Pattern: `**/*.py`

<python_style>
- Follow PEP 8 style guide
- Use type hints for function parameters and return values
- Use docstrings for modules, classes, and functions
- Prefer list comprehensions over loops when readable
- Use f-strings for string formatting
- Keep line length under 88 characters (Black formatter)
</python_style>

<django_models>
- Use descriptive model names in singular form
- Add __str__ methods to all models
- Use proper field types and constraints
- Implement custom managers when needed
- Add model validation in clean() methods
</django_models>

<django_views>
- Use class-based views for complex logic
- Keep views thin, move logic to services
- Use proper HTTP status codes
- Implement proper error handling
- Use Django's built-in authentication
</django_views>

<django_api>
- Use Django REST Framework for APIs
- Implement proper serializers with validation
- Use viewsets for CRUD operations
- Implement proper pagination
- Add API documentation with drf-spectacular
</django_api>

## Django Model Template
```python
from django.db import models
from django.core.validators import MinLengthValidator

class ModelName(models.Model):
    """
    Model description here.
    """

    name = models.CharField(
        max_length=255,
        validators=[MinLengthValidator(2)],
        help_text="Model name"
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Model Name"
        verbose_name_plural = "Model Names"
        ordering = ['-created_at']

    def __str__(self):
        return self.name

    def clean(self):
        """Custom validation logic."""
        super().clean()
        # Add custom validation here
```
EOF

    # Next.js project type rules
    cat > windsurf-rules-bank/project-types/nextjs-app.md << 'EOF'
# Next.js Application Guidelines

**Activation Mode:** Model Decision
**Description:** Apply when working with Next.js applications, App Router, or React Server Components

<app_router>
- Use app directory structure for Next.js 13+
- Implement proper loading and error boundaries
- Use server components by default
- Add 'use client' only when necessary
- Implement proper metadata for SEO
</app_router>

<performance>
- Use Next.js Image component for images
- Implement proper code splitting
- Use dynamic imports for heavy components
- Optimize bundle size with proper imports
- Implement proper caching strategies
</performance>

<routing_navigation>
- Use Next.js Link component for navigation
- Implement proper route groups
- Use parallel routes for complex layouts
- Implement proper error handling
- Use middleware for authentication
</routing_navigation>

<data_fetching>
- Use server components for data fetching
- Implement proper loading states
- Use React Query for client-side data
- Implement proper error boundaries
- Cache data appropriately
</data_fetching>

## Next.js Page Template
```tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Page Title',
  description: 'Page description',
};

interface PageProps {
  params: { id: string };
  searchParams: { [key: string]: string | string[] | undefined };
}

export default async function Page({ params, searchParams }: PageProps) {
  // Server-side data fetching
  const data = await fetchData(params.id);

  return (
    <div>
      <h1>Page Content</h1>
      {/* Page content */}
    </div>
  );
}
```
EOF

    # Code review workflow
    cat > windsurf-rules-bank/workflows/code-review.md << 'EOF'
# Code Review Workflow

**Activation Mode:** Manual (use @code-review to activate)

<review_process>
- Analyze code for adherence to project standards
- Check for potential security vulnerabilities
- Verify proper error handling and edge cases
- Ensure tests cover new functionality
- Review performance implications
- Check documentation completeness
</review_process>

<security_checklist>
- Input validation and sanitization
- SQL injection and XSS vulnerabilities
- Authentication and authorization
- Sensitive data handling
- Proper error messages (no information leakage)
</security_checklist>

<code_quality_checklist>
- Code readability and maintainability
- Proper naming conventions
- Function and class size appropriateness
- Code duplication elimination
- Proper separation of concerns
</code_quality_checklist>

<feedback_guidelines>
- Provide specific, actionable feedback
- Include code examples for suggestions
- Explain reasoning behind recommendations
- Prioritize feedback (critical, important, nice-to-have)
- Be constructive and respectful
</feedback_guidelines>

## Review Template
When performing code reviews, follow this structure:

1. **Overview**: Brief summary of changes
2. **Security**: Any security concerns or improvements
3. **Performance**: Performance implications or optimizations
4. **Code Quality**: Readability, maintainability, and best practices
5. **Testing**: Test coverage and quality
6. **Documentation**: Documentation completeness and accuracy
7. **Recommendations**: Prioritized list of improvements
EOF

    # Debugging context
    cat > windsurf-rules-bank/contexts/debugging.md << 'EOF'
# Debugging Context Rules

**Activation Mode:** Manual (use @debugging to activate)

<debugging_approach>
- Reproduce the issue consistently
- Use systematic debugging techniques
- Add logging at key points
- Use debugger tools effectively
- Document findings and solutions
</debugging_approach>

<analysis_steps>
- Review recent changes that might cause issues
- Check for common patterns that cause bugs
- Verify input validation and error handling
- Review dependencies and their versions
- Check configuration and environment variables
</analysis_steps>

<testing_during_debug>
- Create minimal test cases to reproduce issues
- Test edge cases and boundary conditions
- Verify fixes don't break existing functionality
- Add regression tests for fixed bugs
- Test in different environments
</testing_during_debug>

<logging_strategy>
- Add structured logging with appropriate levels
- Include relevant context in log messages
- Use correlation IDs for request tracking
- Avoid logging sensitive information
- Clean up debug logs before production
</logging_strategy>

## Debugging Checklist
1. **Reproduce**: Can you consistently reproduce the issue?
2. **Isolate**: What's the minimal case that triggers the bug?
3. **Analyze**: What changed recently that might cause this?
4. **Hypothesize**: What are the most likely causes?
5. **Test**: How can you verify your hypothesis?
6. **Fix**: What's the minimal change to resolve the issue?
7. **Verify**: Does the fix work without breaking anything else?
8. **Document**: What did you learn for future reference?
EOF

    # Create README for rules management
    cat > windsurf-rules-bank/README.md << 'EOF'
# Windsurf Rules Bank

This directory contains a collection of rule files that can be activated in the `.windsurf/rules/` folder as needed.

## Structure

- `frameworks/` - Framework and language-specific rules
- `project-types/` - Rules for different types of projects
- `workflows/` - Workflow and process-specific rules
- `standards/` - Coding standards and conventions
- `contexts/` - Context-specific rules (debugging, refactoring, etc.)

## Activation Modes

Windsurf supports 4 activation modes:

1. **Manual** - Activated via `@mention` in Cascade's input box
2. **Always On** - Always applied to all conversations
3. **Model Decision** - AI decides when to apply based on description
4. **Glob** - Applied when files matching pattern are referenced

## Usage

To activate rules, copy them from this bank to the `.windsurf/rules/` folder:

```bash
# Activate Python/Django rules
cp windsurf-rules-bank/frameworks/python-django.md .windsurf/rules/

# Activate Next.js project rules
cp windsurf-rules-bank/project-types/nextjs-app.md .windsurf/rules/

# Activate code review workflow
cp windsurf-rules-bank/workflows/code-review.md .windsurf/rules/
```

## Managing Rules

You can manage rules through:

1. Windsurf Customizations panel (top-right slider menu in Cascade)
2. Windsurf Settings (bottom-right corner)
3. Create memories by asking Cascade to "create a memory of..."
4. Use `@rule-name` to manually activate specific rules

## Global Rules

Move the `global_rules.md` file to your Windsurf global rules location:
- The file will be applied across all workspaces
- Access via Windsurf Settings → Rules → Global

## Best Practices

- Keep rules simple, concise, and specific
- Use bullet points, numbered lists, and markdown formatting
- Use XML tags to group similar rules together
- Avoid generic rules (already in Windsurf's training)
- Rules are limited to 12,000 characters each
- Test rules to ensure they work as expected

## Memory System

Windsurf also supports automatic memory generation:
- Cascade can automatically create memories during conversations
- Memories are workspace-specific
- Ask Cascade to "create a memory of..." for manual memory creation
- Memories don't consume credits
EOF

    # Create VS Code workspace
    setup_vscode_workspace

    # Copy TypeScript/React rules
    copy_typescript_react_rules

    print_color $GREEN "Windsurf setup completed!"
    print_color $YELLOW "Created Windsurf rules structure:"
    echo "  ✓ .windsurf/rules/ - Workspace rules folder"
    echo "  ✓ windsurf-rules-bank/ - Rules repository"
    echo "  ✓ global_rules.md - Global rules template"
    echo "  ✓ .vscode/ - VS Code workspace with MCP configuration"
    echo "  ✓ Always-on coding standards"
    echo "  ✓ Glob-based TypeScript/React rules"
    echo "  ✓ Model-decision API development rules"
    echo "  ✓ Manual testing and debugging rules"
    echo "  ✓ Framework-specific rules (Python/Django, Next.js)"
    echo "  ✓ Workflow rules (code review, debugging)"
    echo "  ✓ TypeScript/React rules (TypeScript, ShadCN UI, Tailwind CSS)"
    echo
    print_color $YELLOW "Next steps:"
    echo "1. Install Windsurf from https://windsurf.com if not already installed"
    echo "2. Move global_rules.md to your Windsurf global rules location"
    echo "3. Open Windsurf and access Customizations → Rules to manage rules"
    echo "4. Activate additional rules from windsurf-rules-bank/ as needed"
    echo "5. Use @rule-name to manually activate specific rules in Cascade"
    echo "6. Ask Cascade to 'create a memory of...' for automatic memory generation"
    echo "7. Explore rule templates at https://windsurf.com/editor/directory"
}

# Function to setup Augment
setup_augment() {
    print_header "Setting up Augment"

    # Check if VS Code is installed (Augment primarily works with VS Code)
    if ! command -v code &> /dev/null; then
        print_color $YELLOW "VS Code not found. Augment extension will need to be installed manually."
    else
        print_color $GREEN "VS Code detected. Augment extension can be installed from marketplace."
    fi

    # Create Augment rules structure
    print_color $YELLOW "Creating Augment rules structure..."
    mkdir -p .augment/rules
    mkdir -p augment-rules-bank/{frameworks,project-types,workflows,standards,contexts}

    # Create always-applied coding standards rule
    cat > .augment/rules/coding-standards.md << 'EOF'
# Coding Standards

**Rule Type:** Always

## General Guidelines
- Write clean, readable, and maintainable code
- Follow existing code style and patterns in the project
- Use descriptive variable and function names
- Add meaningful comments for complex logic
- Prefer composition over inheritance
- Handle errors gracefully with proper error messages

## Code Quality
- Validate input parameters and handle edge cases
- Use appropriate data structures for the task
- Optimize for readability first, performance second
- Follow SOLID principles where applicable
- Write tests for new functionality

## Security Best Practices
- Sanitize user inputs and validate data
- Avoid hardcoding sensitive information
- Follow principle of least privilege
- Use secure coding practices
- Implement proper authentication and authorization

## Documentation Requirements
- Update relevant documentation when modifying features
- Keep README.md in sync with new capabilities
- Document public APIs and complex functions
- Include usage examples in documentation
- Maintain changelog entries for significant changes
EOF

    # Create auto-detected TypeScript/React rule
    cat > .augment/rules/typescript-react.md << 'EOF'
# TypeScript and React Development Guidelines

**Rule Type:** Auto
**Description:** Guidelines for TypeScript and React development, including component patterns, hooks usage, and type safety practices

## TypeScript Best Practices
- Use strict TypeScript configuration with strict mode enabled
- Prefer interfaces over types for object shapes and component props
- Use union types for controlled values and state management
- Implement proper error handling with Result types or error boundaries
- Use generic types for reusable components and utility functions
- Prefer readonly arrays and objects when data shouldn't be mutated

## React Component Guidelines
- Use functional components with hooks instead of class components
- Follow React hooks rules (no conditional hooks, hooks at top level)
- Use React.FC type for components that accept children
- Keep components small and focused (single responsibility principle)
- Use proper key props for lists and dynamic content
- Implement proper error boundaries for error handling
- Use CSS modules, styled-components, or Tailwind for styling

## State Management
- Use useState for local component state
- Use useReducer for complex state logic
- Use useContext for sharing state across components
- Consider external state management (Redux, Zustand) for complex apps
- Keep state minimal and normalized
- Avoid prop drilling with proper state architecture

## Performance Optimization
- Use React.memo for expensive components
- Use useMemo and useCallback for expensive computations
- Implement code splitting with React.lazy and Suspense
- Optimize bundle size with proper imports
- Use React DevTools for performance profiling

## Naming Conventions
- Use PascalCase for component names and interfaces
- Use camelCase for variables, functions, and methods
- Use UPPER_SNAKE_CASE for constants and environment variables
- Prefix custom hooks with 'use' (e.g., useCustomHook)
- Use descriptive names that explain purpose and behavior

## Component Template Example
```tsx
import React, { useState, useEffect } from 'react';

interface ComponentNameProps {
  title: string;
  onAction?: (data: string) => void;
  children?: React.ReactNode;
}

export const ComponentName: React.FC<ComponentNameProps> = ({
  title,
  onAction,
  children
}) => {
  const [state, setState] = useState<string>('');

  useEffect(() => {
    // Effect logic here
  }, []);

  const handleClick = () => {
    if (onAction) {
      onAction(state);
    }
  };

  return (
    <div className="component-name">
      <h2>{title}</h2>
      {children}
      <button onClick={handleClick}>Action</button>
    </div>
  );
};

export default ComponentName;
```
EOF

    # Create manual testing standards rule
    cat > .augment/rules/testing-standards.md << 'EOF'
# Testing Standards and Best Practices

**Rule Type:** Manual
**Usage:** Use @testing-standards when working on tests or discussing testing strategies

## Test Requirements
- Unit tests required for all business logic and utility functions
- Integration tests for API endpoints and database interactions
- End-to-end tests for critical user flows and workflows
- Test coverage should be meaningful, not just high percentage
- Tests should be fast, reliable, and independent

## Test Structure and Organization
- Use descriptive test names that explain what is being tested
- Follow AAA pattern (Arrange, Act, Assert) for test structure
- Use appropriate test fixtures and mocks for external dependencies
- Group related tests in describe blocks or test suites
- Keep test files close to the code they test

## Test Quality Guidelines
- Make tests independent and isolated from each other
- Use meaningful assertions that verify expected behavior
- Test one thing at a time to maintain clarity
- Include both positive and negative test cases
- Test edge cases and boundary conditions
- Mock external dependencies and services

## Testing Frameworks and Tools
- Use Jest for JavaScript/TypeScript unit and integration tests
- Use React Testing Library for React component testing
- Use Cypress or Playwright for end-to-end testing
- Use MSW (Mock Service Worker) for API mocking
- Use Factory functions or libraries for test data generation

## Test Data Management
- Use factory functions to create test data
- Keep test data separate from test logic
- Use realistic but anonymized data for tests
- Clean up test data after tests complete
- Use database transactions for integration tests

## Test Template Example
```typescript
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { ComponentName } from './ComponentName';

describe('ComponentName', () => {
  const mockProps = {
    title: 'Test Title',
    onAction: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe('when rendered with valid props', () => {
    it('should display the title correctly', () => {
      render(<ComponentName {...mockProps} />);

      expect(screen.getByText('Test Title')).toBeInTheDocument();
    });

    it('should call onAction when button is clicked', () => {
      render(<ComponentName {...mockProps} />);

      const button = screen.getByRole('button', { name: /action/i });
      fireEvent.click(button);

      expect(mockProps.onAction).toHaveBeenCalledTimes(1);
    });
  });

  describe('error handling', () => {
    it('should handle missing onAction prop gracefully', () => {
      const propsWithoutAction = { title: 'Test Title' };

      expect(() => {
        render(<ComponentName {...propsWithoutAction} />);
      }).not.toThrow();
    });
  });

  describe('edge cases', () => {
    it('should handle empty title', () => {
      render(<ComponentName {...mockProps} title="" />);

      expect(screen.getByText('')).toBeInTheDocument();
    });
  });
});
```
EOF

    # Create auto-detected API development rule
    cat > .augment/rules/api-development.md << 'EOF'
# API Development Guidelines

**Rule Type:** Auto
**Description:** Guidelines for REST API development, including endpoint design, validation, error handling, and security practices

## RESTful API Design Principles
- Follow RESTful conventions for URL structure and HTTP methods
- Use consistent naming patterns for endpoints (plural nouns)
- Implement proper HTTP status codes (200, 201, 400, 401, 404, 500, etc.)
- Version your APIs using URL versioning (e.g., /api/v1/)
- Use JSON for request and response bodies
- Implement proper content-type headers

## Request and Response Handling
- Validate all input data using schema validation libraries
- Use consistent response formats across all endpoints
- Implement proper pagination for list endpoints
- Include metadata in responses (timestamps, pagination info)
- Handle file uploads and downloads appropriately
- Implement request/response logging for debugging

## Error Handling and Validation
- Return consistent error response formats
- Include error codes and descriptive messages
- Validate input data at the API boundary
- Use middleware for common error scenarios
- Log errors with appropriate detail and context
- Implement proper exception handling throughout the stack

## Security Best Practices
- Implement authentication and authorization for all endpoints
- Use HTTPS in production environments
- Validate and sanitize all user inputs
- Implement rate limiting and throttling
- Use secure headers (CORS, CSP, etc.)
- Avoid exposing sensitive information in error messages

## Performance and Scalability
- Implement caching strategies where appropriate
- Use database indexing effectively for queries
- Implement connection pooling for database connections
- Monitor API performance and response times
- Use compression for large responses
- Implement proper timeout handling

## Documentation and Testing
- Document all endpoints with OpenAPI/Swagger specifications
- Include request/response examples in documentation
- Write comprehensive API tests (unit, integration, e2e)
- Test error scenarios and edge cases
- Maintain up-to-date API documentation
- Use API testing tools like Postman or Insomnia

## API Endpoint Template Example
```typescript
import { z } from 'zod';
import { Request, Response, NextFunction } from 'express';
import { ApiError } from '../utils/errors';

// Request validation schemas
const CreateUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  age: z.number().min(18).max(120).optional(),
});

const UpdateUserSchema = CreateUserSchema.partial();

// Response schemas
const UserResponseSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string(),
  age: z.number().optional(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

// Types
export type CreateUserRequest = z.infer<typeof CreateUserSchema>;
export type UpdateUserRequest = z.infer<typeof UpdateUserSchema>;
export type UserResponse = z.infer<typeof UserResponseSchema>;

// Controller functions
export const createUser = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    // Validate request body
    const userData = CreateUserSchema.parse(req.body);

    // Business logic
    const user = await userService.createUser(userData);

    // Return response
    const response: UserResponse = {
      id: user.id,
      name: user.name,
      email: user.email,
      age: user.age,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };

    res.status(201).json({
      success: true,
      data: response,
      message: 'User created successfully',
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return next(new ApiError(400, 'Validation failed', error.errors));
    }
    next(error);
  }
};

export const getUser = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { id } = req.params;

    const user = await userService.getUserById(id);

    if (!user) {
      return next(new ApiError(404, 'User not found'));
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
};
```
EOF

    # Create legacy workspace guidelines file
    cat > .augment-guidelines << 'EOF'
# Workspace Guidelines (Legacy)

This file provides workspace-level guidelines for Augment Agent and Chat.
Note: This is the legacy format. Consider migrating to the new Rules system in .augment/rules/

## Project-Specific Guidelines
- Follow the existing code patterns and architecture in this project
- Use the project's preferred testing framework and patterns
- Maintain consistency with the project's documentation style
- Follow the project's git commit message conventions

## Technology Stack Preferences
- Specify preferred libraries and frameworks used in this project
- Document any deprecated or discouraged patterns
- Include version-specific requirements or constraints
- Note any project-specific configuration requirements

## Code Style and Patterns
- Follow the project's linting and formatting rules
- Use established naming conventions for files and functions
- Maintain consistency with existing error handling patterns
- Follow the project's logging and debugging practices

## Documentation Requirements
- Update relevant documentation when making changes
- Follow the project's documentation format and style
- Include examples and usage instructions for new features
- Maintain accurate and up-to-date README files
EOF

    # Create VS Code workspace
    setup_vscode_workspace

    # Copy TypeScript/React rules
    copy_typescript_react_rules

    print_color $GREEN "Augment setup completed!"
    print_color $YELLOW "Created Augment rules structure:"
    echo "  ✓ .augment/rules/ - Rules directory"
    echo "  ✓ .augment-guidelines - Legacy workspace guidelines"
    echo "  ✓ .vscode/ - VS Code workspace with MCP configuration"
    echo "  ✓ Always-applied coding standards rule"
    echo "  ✓ Auto-detected TypeScript/React rule"
    echo "  ✓ Manual testing standards rule"
    echo "  ✓ Auto-detected API development rule"
    echo "  ✓ TypeScript/React rules (TypeScript, ShadCN UI, Tailwind CSS)"
    echo
    print_color $YELLOW "Next steps:"
    echo "1. Install the Augment extension from VS Code marketplace"
    echo "2. Sign up for Augment at https://app.augmentcode.com"
    echo "3. Configure your API key in the Augment extension"
    echo "4. Access Rules via Settings > User Guidelines and Rules"
    echo "5. Use @ mentions to access User Guidelines and Rules"
    echo "6. Import existing rules from other tools if needed"
    echo "7. Create additional rules in .augment/rules/ as needed"
}

# Function to setup Roo Code
setup_roo_code() {
    print_header "Setting up Roo Code"

    # Check if VS Code is installed (Roo Code is a VS Code extension)
    if ! command -v code &> /dev/null; then
        print_color $YELLOW "VS Code not found. Roo Code extension will need to be installed manually."
    else
        print_color $GREEN "VS Code detected. Roo Code extension can be installed from marketplace."
    fi

    # Create Roo Code rules structure
    print_color $YELLOW "Creating Roo Code rules structure..."

    # Create workspace rules directories
    mkdir -p .roo/rules
    mkdir -p .roo/rules-code
    mkdir -p .roo/rules-docs-extractor
    mkdir -p .roo/rules-architect
    mkdir -p .roo/rules-debug

    # Create rules bank for easy management
    mkdir -p roo-rules-bank/{global,workspace,mode-specific,frameworks,project-types}

    # Create global rules directory (user will need to copy these manually)
    print_color $YELLOW "Creating global rules templates..."
    mkdir -p global-roo-rules/{rules,rules-code,rules-docs-extractor,rules-architect,rules-debug}

    # Create global coding standards
    cat > global-roo-rules/rules/01-coding-standards.md << 'EOF'
# Global Coding Standards

## General Guidelines
- Write clean, readable, and maintainable code
- Follow existing code style and patterns in the project
- Use descriptive variable and function names
- Add meaningful comments for complex logic
- Prefer composition over inheritance
- Handle errors gracefully with proper error messages

## Code Quality
- Validate input parameters and handle edge cases
- Use appropriate data structures for the task
- Optimize for readability first, performance second
- Follow SOLID principles where applicable
- Write tests for new functionality

## Security Best Practices
- Sanitize user inputs and validate data
- Avoid hardcoding sensitive information
- Follow principle of least privilege
- Use secure coding practices
- Implement proper authentication and authorization

## Documentation Requirements
- Update relevant documentation when modifying features
- Keep README.md in sync with new capabilities
- Document public APIs and complex functions
- Include usage examples in documentation
- Maintain changelog entries for significant changes
EOF

    # Create global formatting rules
    cat > global-roo-rules/rules/02-formatting-rules.md << 'EOF'
# Global Formatting Rules

## Indentation and Spacing
- Always use spaces for indentation, with a width of 4 spaces
- Use consistent spacing around operators and keywords
- Add blank lines to separate logical sections
- Keep line length under 100 characters when possible

## Naming Conventions
- Use camelCase for variable names and function names
- Use PascalCase for class names and interfaces
- Use UPPER_SNAKE_CASE for constants
- Use descriptive names that explain purpose

## Code Organization
- Group related functions and classes together
- Use consistent file and folder naming conventions
- Organize imports at the top of files
- Separate concerns into different modules/files

## Comments and Documentation
- Write JSDoc comments for public APIs
- Explain complex algorithms and business logic
- Keep comments up to date with code changes
- Use TODO comments for future improvements
EOF

    # Create global security guidelines
    cat > global-roo-rules/rules/03-security-guidelines.md << 'EOF'
# Global Security Guidelines

## Input Validation
- Validate all user inputs at the application boundary
- Use parameterized queries to prevent SQL injection
- Sanitize data before displaying to prevent XSS
- Implement proper file upload restrictions

## Authentication and Authorization
- Use strong authentication mechanisms
- Implement proper session management
- Follow principle of least privilege
- Use secure password storage (hashing + salting)

## Data Protection
- Encrypt sensitive data at rest and in transit
- Use HTTPS for all web communications
- Implement proper error handling without information leakage
- Follow data privacy regulations (GDPR, CCPA, etc.)

## Dependency Management
- Keep dependencies up to date
- Regularly audit for security vulnerabilities
- Use dependency scanning tools
- Avoid dependencies with known security issues
EOF

    # Create code mode specific rules
    cat > global-roo-rules/rules-code/01-typescript-rules.md << 'EOF'
# TypeScript Code Mode Rules

## TypeScript Configuration
- Use strict mode in tsconfig.json
- Enable all strict type checking options
- Use noImplicitAny and noImplicitReturns
- Configure proper module resolution

## Type Definitions
- Prefer interfaces over type aliases for object shapes
- Always specify return types for functions
- Use union types for controlled values
- Implement proper error handling with Result types
- Use generic types for reusable components

## Code Patterns
- Use functional programming patterns where appropriate
- Prefer immutable data structures
- Use async/await over Promises for better readability
- Implement proper error boundaries in React applications

## Testing Requirements
- Write unit tests for all new functions
- Use type-safe mocking in tests
- Test edge cases and error conditions
- Maintain good test coverage
EOF

    # Create workspace-wide rules
    cat > .roo/rules/01-project-standards.md << 'EOF'
# Project-Specific Standards

## Project Guidelines
- Follow the existing code patterns and architecture in this project
- Use the project's preferred testing framework and patterns
- Maintain consistency with the project's documentation style
- Follow the project's git commit message conventions

## Technology Stack
- Use the specific versions of libraries defined in package.json
- Follow project-specific configuration requirements
- Respect any deprecated or discouraged patterns in this project
- Use project-approved libraries and frameworks

## Development Workflow
- Run linting and formatting before committing
- Write meaningful commit messages
- Update tests when modifying functionality
- Update documentation for user-facing changes

## Code Review Guidelines
- Focus on code readability and maintainability
- Ensure proper error handling
- Verify test coverage for new features
- Check for security vulnerabilities
EOF

    # Create code mode workspace rules
    cat > .roo/rules-code/01-project-code-style.md << 'EOF'
# Project Code Style Guidelines

## Language-Specific Rules
- Use the project's configured linter settings
- Follow the established patterns for this codebase
- Respect existing naming conventions
- Use the project's preferred import/export patterns

## Framework Guidelines
- Follow framework-specific best practices
- Use established patterns for state management
- Implement proper component lifecycle management
- Follow the project's routing and navigation patterns

## Performance Considerations
- Optimize for the project's performance requirements
- Use appropriate caching strategies
- Implement lazy loading where beneficial
- Monitor bundle size and performance metrics

## Testing Strategy
- Use the project's testing framework
- Follow established testing patterns
- Mock external dependencies appropriately
- Write integration tests for critical paths
EOF

    # Create documentation extractor rules
    cat > .roo/rules-docs-extractor/01-documentation-style.md << 'EOF'
# Documentation Style Guidelines

## Documentation Format
- Use clear, concise language
- Structure documentation with proper headings
- Include practical examples and use cases
- Maintain consistent formatting throughout

## API Documentation
- Document all public methods and properties
- Include parameter types and return values
- Provide usage examples for complex APIs
- Document error conditions and exceptions

## Code Comments
- Explain the "why" not just the "what"
- Keep comments up to date with code changes
- Use consistent comment formatting
- Document complex algorithms and business logic

## README Requirements
- Include installation and setup instructions
- Provide usage examples and tutorials
- Document configuration options
- Include troubleshooting guides
EOF

    # Create architect mode rules
    cat > .roo/rules-architect/01-architecture-principles.md << 'EOF'
# Architecture Principles

## System Design
- Design for scalability and maintainability
- Use appropriate design patterns
- Implement proper separation of concerns
- Plan for future extensibility

## Technology Choices
- Choose technologies based on project requirements
- Consider long-term maintenance and support
- Evaluate performance implications
- Assess team expertise and learning curve

## Documentation Requirements
- Create architecture decision records (ADRs)
- Document system dependencies and integrations
- Maintain up-to-date system diagrams
- Document deployment and operational procedures

## Quality Attributes
- Design for reliability and availability
- Implement proper monitoring and observability
- Plan for security from the ground up
- Consider performance and scalability requirements
EOF

    # Create debug mode rules
    cat > .roo/rules-debug/01-debugging-approach.md << 'EOF'
# Debugging Approach

## Systematic Debugging
- Reproduce the issue consistently
- Use systematic debugging techniques
- Add logging at key points
- Use debugger tools effectively
- Document findings and solutions

## Analysis Steps
- Review recent changes that might cause issues
- Check for common patterns that cause bugs
- Verify input validation and error handling
- Review dependencies and their versions
- Check configuration and environment variables

## Testing During Debug
- Create minimal test cases to reproduce issues
- Test edge cases and boundary conditions
- Verify fixes don't break existing functionality
- Add regression tests for fixed bugs
- Test in different environments

## Documentation
- Document the debugging process
- Record solutions for future reference
- Update troubleshooting guides
- Share knowledge with the team
EOF

    # Create rules bank examples

    # Framework-specific rules
    cat > roo-rules-bank/frameworks/react-nextjs.md << 'EOF'
# React and Next.js Guidelines

## React Best Practices
- Use functional components with hooks
- Follow React hooks rules (no conditional hooks)
- Use React.FC type for components with children
- Keep components small and focused
- Use proper key props for lists
- Implement proper error boundaries

## Next.js Specific
- Use App Router for Next.js 13+
- Implement proper loading and error boundaries
- Use server components by default
- Add 'use client' only when necessary
- Implement proper metadata for SEO
- Use Next.js Image component for images

## Performance
- Implement proper code splitting
- Use dynamic imports for heavy components
- Optimize bundle size with proper imports
- Implement proper caching strategies
- Use React Query for client-side data

## State Management
- Use useState for local component state
- Use useContext for sharing state across components
- Consider external state management for complex apps
- Keep state minimal and normalized
EOF

    # Project type rules
    cat > roo-rules-bank/project-types/api-service.md << 'EOF'
# API Service Guidelines

## RESTful API Design
- Follow RESTful principles and conventions
- Use consistent URL patterns and naming
- Implement proper HTTP status codes
- Version your APIs (e.g., /api/v1/)
- Use JSON for request/response bodies

## Error Handling
- Return consistent error response format
- Include error codes and descriptive messages
- Log errors with appropriate detail
- Implement proper exception handling
- Use middleware for common error scenarios

## Security
- Implement authentication and authorization
- Use HTTPS in production
- Validate and sanitize all user inputs
- Implement rate limiting and throttling
- Use secure headers (CORS, CSP, etc.)

## Performance
- Implement caching where appropriate
- Use database indexing effectively
- Implement pagination for large datasets
- Monitor API performance metrics
- Use connection pooling
EOF

    # Create legacy .roorules file for backward compatibility
    cat > .roorules << 'EOF'
# Legacy Roo Code Rules (Fallback)

This file provides workspace-level rules for Roo Code.
Note: The preferred method is using .roo/rules/ directory.

## General Guidelines
- Follow the existing code patterns and architecture in this project
- Write clean, readable, and maintainable code
- Use descriptive variable and function names
- Add meaningful comments for complex logic

## Code Quality
- Write unit tests for all new functions
- Handle errors gracefully with proper error messages
- Validate input parameters and handle edge cases
- Follow SOLID principles where applicable

## Documentation
- Update relevant documentation when modifying features
- Keep README.md in sync with new capabilities
- Document public APIs and complex functions
- Include usage examples in documentation
EOF

    # Create README for rules management
    cat > roo-rules-bank/README.md << 'EOF'
# Roo Code Rules Bank

This directory contains a collection of rule files that can be used with Roo Code's custom instructions system.

## Structure

- `global/` - Templates for global rules (copy to ~/.roo/)
- `workspace/` - Templates for workspace-specific rules
- `mode-specific/` - Rules for specific Roo Code modes
- `frameworks/` - Framework and language-specific rules
- `project-types/` - Rules for different types of projects

## Global Rules Setup

Copy global rules to your global Roo directory:

```bash
# Linux/macOS
cp -r global-roo-rules/* ~/.roo/

# Windows
xcopy global-roo-rules %USERPROFILE%\.roo\ /E /I
```

## Workspace Rules

Workspace rules are already set up in `.roo/rules/` and mode-specific directories.

## Rule Loading Order

Roo Code loads rules in this order:
1. Global rules (from ~/.roo/)
2. Workspace rules (from .roo/) - can override global rules
3. Legacy files (.roorules) - for backward compatibility

## Directory Structure

```
.roo/
├── rules/                    # Workspace-wide rules
├── rules-code/              # Code mode specific rules
├── rules-docs-extractor/    # Documentation mode rules
├── rules-architect/         # Architecture mode rules
└── rules-debug/             # Debug mode rules
```

## Usage Tips

- Use global rules for organization-wide standards
- Use workspace rules for project-specific requirements
- Use mode-specific rules for specialized workflows
- Files are loaded in alphabetical order by filename
- Use numbered prefixes (01-, 02-) to control loading order

## Best Practices

- Keep rules focused and specific
- Use clear, actionable language
- Organize rules by concern or domain
- Test rules to ensure they work as expected
- Version control workspace rules for team consistency
EOF

    # Create VS Code workspace
    setup_vscode_workspace

    # Copy TypeScript/React rules
    copy_typescript_react_rules

    print_color $GREEN "Roo Code setup completed!"
    print_color $YELLOW "Created Roo Code rules structure:"
    echo "  ✓ .roo/rules/ - Workspace-wide rules"
    echo "  ✓ .roo/rules-code/ - Code mode specific rules"
    echo "  ✓ .roo/rules-docs-extractor/ - Documentation mode rules"
    echo "  ✓ .roo/rules-architect/ - Architecture mode rules"
    echo "  ✓ .roo/rules-debug/ - Debug mode rules"
    echo "  ✓ global-roo-rules/ - Global rules templates"
    echo "  ✓ roo-rules-bank/ - Rules repository"
    echo "  ✓ .roorules - Legacy fallback file"
    echo "  ✓ .vscode/ - VS Code workspace with MCP configuration"
    echo "  ✓ TypeScript/React rules (TypeScript, ShadCN UI, Tailwind CSS)"
    echo
    print_color $YELLOW "Next steps:"
    echo "1. Install Roo Code extension from VS Code marketplace"
    echo "2. Copy global rules to your global directory:"
    echo "   Linux/macOS: cp -r global-roo-rules/* ~/.roo/"
    echo "   Windows: xcopy global-roo-rules %USERPROFILE%\\.roo\\ /E /I"
    echo "3. Configure Roo Code with your preferred AI provider"
    echo "4. Access custom instructions via Prompts tab in Roo Code"
    echo "5. Customize rules in .roo/ directories for this project"
    echo "6. Use mode-specific rules for specialized workflows"
    echo "7. Add project-specific rules from roo-rules-bank/ as needed"
}

# Function to setup other AI assistants (placeholder)
setup_other_assistant() {
    local assistant=$1
    print_header "Setting up $assistant"

    print_color $YELLOW "$assistant setup is not yet implemented."
    print_color $BLUE "Please refer to $assistant documentation for setup instructions."
}

# Function to setup AI assistant based on user choice
setup_ai_assistant() {
    case $AI_ASSISTANT in
        "github-copilot")
            setup_github_copilot
            ;;
        "cline")
            setup_cline
            ;;
        "cursor")
            setup_cursor
            ;;
        "windsurf")
            setup_windsurf
            ;;
        "augment")
            setup_augment
            ;;
        "roo-code")
            setup_roo_code
            ;;
        "none")
            print_color $YELLOW "Skipping AI assistant setup."
            ;;
    esac
}



# Function to ask if user wants to create a new project
ask_create_project() {
    echo
    read -p "Do you want to create a new project folder with these AI assistant configurations? (y/n): " create_project
    if [[ $create_project =~ ^[Yy]$ ]]; then
        echo
        read -p "Enter the project name: " project_name

        # Validate project name
        if [[ -z "$project_name" ]]; then
            print_color $RED "Project name cannot be empty."
            return 1
        fi

        # Remove any spaces and special characters for folder name
        folder_name=$(echo "$project_name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')

        if [[ -z "$folder_name" ]]; then
            print_color $RED "Invalid project name. Please use alphanumeric characters."
            return 1
        fi

        # Check if folder already exists
        if [[ -d "$folder_name" ]]; then
            print_color $RED "Folder '$folder_name' already exists."
            read -p "Do you want to overwrite it? (y/n): " overwrite
            if [[ ! $overwrite =~ ^[Yy]$ ]]; then
                return 1
            fi
            rm -rf "$folder_name"
        fi

        create_project_folder "$folder_name" "$project_name"
    fi
}

# Function to create project folder with AI assistant configurations
create_project_folder() {
    local folder_name=$1
    local project_name=$2

    print_header "Creating Project: $project_name"

    # Create project directory
    mkdir -p "$folder_name"
    cd "$folder_name"

    # Setup AI assistant in the new project folder
    setup_ai_assistant

    # Create basic project structure
    mkdir -p src docs

    # Create project README
    cat > README.md << EOF
# $project_name

This project has been configured with AI assistant rules and templates.

## AI Assistant Configuration

This project includes configuration for: **$AI_ASSISTANT**

### Getting Started

1. Open this project in your preferred editor
2. Install the required AI assistant extension if not already installed
3. The AI assistant will automatically use the configured rules and templates

### Project Structure

- \`src/\` - Source code and implementation files
- \`docs/\` - Project documentation
- AI assistant configuration files are in their respective directories

### Next Steps

1. Review and customize the AI assistant rules for your specific needs
2. Start coding with your AI assistant using the configured guidelines
3. Add your project-specific requirements and documentation

## Development

Your AI assistant is configured with:
- Coding standards and best practices
- Framework-specific guidelines
- Testing standards and templates
- Security best practices
- Documentation requirements

Happy coding with AI assistance! 🚀
EOF

    # Create basic package.json if it doesn't exist
    if [[ ! -f "package.json" ]]; then
        cat > package.json << EOF
{
  "name": "$folder_name",
  "version": "1.0.0",
  "description": "$project_name - AI-assisted development project",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": ["ai-assisted", "development"],
  "author": "",
  "license": "MIT"
}
EOF
    fi

    # Create basic .gitignore
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Dependency directories
node_modules/
jspm_packages/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env
.env.test
.env.local
.env.production

# IDE files
.vscode/settings.json
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Build outputs
dist/
build/
*.log
EOF

    # Go back to original directory
    cd ..

    print_color $GREEN "Project '$project_name' created successfully!"
    print_color $YELLOW "Project location: $(pwd)/$folder_name"
    echo
    print_color $CYAN "Next steps:"
    echo "1. Move the project folder to your preferred projects directory:"
    print_color $BLUE "   mv $folder_name /path/to/your/projects/"
    echo "2. Open the project in your editor:"
    print_color $BLUE "   cd /path/to/your/projects/$folder_name"
    print_color $BLUE "   code . # for VS Code"
    echo "3. Install dependencies if needed:"
    print_color $BLUE "   npm install # or yarn install"
    echo "4. Start coding with your configured AI assistant!"
    echo
    print_color $YELLOW "The project includes:"
    echo "  ✓ AI assistant configuration for $AI_ASSISTANT"
    echo "  ✓ Professional coding standards and templates"
    echo "  ✓ Basic project structure (src/, docs/)"
    echo "  ✓ README.md with setup instructions"
    echo "  ✓ package.json and .gitignore files"
}

# Cleanup function for temporary files and error handling
cleanup() {
    local exit_code=$?

    # Remove any temporary files if they exist
    if [[ -n "${TEMP_DIR:-}" ]] && [[ -d "${TEMP_DIR}" ]]; then
        rm -rf "${TEMP_DIR}"
    fi

    if [[ ${exit_code} -ne 0 ]]; then
        print_color "${RED}" "Script exited with error code ${exit_code}"
    fi

    exit ${exit_code}
}

# Set up signal handlers for cleanup
trap cleanup EXIT
trap 'cleanup' INT TERM

# Function to initialize script environment
init_script() {
    # Create temporary directory for any temp files
    TEMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'ai-setup')

    # Check dependencies
    check_dependencies

    # Validate environment
    if [[ ! -w "." ]]; then
        print_color "${RED}" "Error: Current directory is not writable"
        exit 1
    fi

    print_color "${GREEN}" "Environment checks passed successfully"
}

# Main execution function
main() {
    # Parse command line arguments first
    parse_arguments "$@"

    # Initialize script environment
    init_script

    print_header "${SCRIPT_NAME} v${SCRIPT_VERSION}"

    if [[ "${DRY_RUN}" == "true" ]]; then
        print_color "${BLUE}" "DRY RUN MODE: No changes will be made"
        echo
    fi

    # Ask user about AI assistant preference (unless specified via CLI)
    if [[ -z "${AI_ASSISTANT:-}" ]]; then
        ask_ai_assistant
    else
        print_color "${GREEN}" "Using AI assistant: ${AI_ASSISTANT}"
    fi

    # Ask if user wants to create a new project or just configure current directory
    echo
    print_color "${YELLOW}" "Setup Options:"
    echo "1. Configure current directory with AI assistant rules"
    echo "2. Create a new project folder with AI assistant configuration"
    echo

    local setup_option
    read -p "Choose option (1 or 2): " setup_option

    case ${setup_option} in
        1)
            print_color "${CYAN}" "Configuring current directory..."
            setup_ai_assistant
            ;;
        2)
            ask_create_project
            ;;
        *)
            print_color "${RED}" "Invalid option. Configuring current directory..."
            setup_ai_assistant
            ;;
    esac

    print_header "Setup Complete!"

    if [[ ${setup_option} == "1" ]]; then
        print_color "${GREEN}" "Your current directory has been configured with AI assistant rules."

        if [[ "${AI_ASSISTANT}" != "none" ]]; then
            print_color "${YELLOW}" "Please restart your editor to apply all AI assistant settings."
        fi
    else
        print_color "${GREEN}" "Project creation completed! Follow the instructions above to get started."
    fi

    print_color "${GREEN}" "Script completed successfully!"
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
