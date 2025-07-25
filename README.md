# AI-Assisted Development Environment Setup

This project provides a comprehensive setup script that automatically configures your development environment for optimal AI coding assistant integration. The script detects and configures **six major AI coding assistants** with their native rule systems, best practices, and professional-grade templates.

## 🚀 Key Features

### **Universal AI Assistant Configuration**
- **GitHub Copilot** - Instructions files, prompt files, and VS Code integration
- **Cline** - Rules-based system with contextual activation
- **Cursor** - MDC rules with auto-attachment and templates
- **Windsurf** - Memories & rules system with XML formatting
- **Augment** - Rules & Guidelines with Always/Manual/Auto modes
- **Roo Code** - Hierarchical custom instructions with mode-specific rules

### **Professional Development Templates**
- Requirements documentation with EARS syntax
- Technical design specifications
- Implementation task management
- Testing standards and templates
- Security best practices
- Framework-specific guidelines



### **Team Collaboration Ready**
- Version-controlled rules and guidelines
- Consistent coding standards across team members
- Project-specific customization capabilities
- Organization-wide best practices

### **Enhanced Script Features (v2.0)**
- **Robust Error Handling** - Comprehensive validation and graceful error recovery
- **Dry-Run Mode** - Preview changes before applying them
- **Dependency Checking** - Automatic validation of required tools and versions
- **Command Line Interface** - Full CLI support with help, version, and options
- **Signal Handling** - Proper cleanup on interruption or errors
- **Cross-Platform** - Improved portability across different systems
- **Professional Output** - Color-coded messages with clear status indicators

---

## 🎯 Quick Start

### **One-Command Setup**
```bash
chmod +x setup.sh
./setup.sh
```

### **Command Line Options**
```bash
# Interactive setup (recommended)
./setup.sh

# Show help and all available options
./setup.sh --help

# Setup specific AI assistant directly
./setup.sh --assistant cursor

# Preview changes without applying them
./setup.sh --dry-run

# Run without colored output
./setup.sh --no-color

# Show version information
./setup.sh --version
```

The setup script will:
1. **Detect your AI coding assistant preference** (GitHub Copilot, Cline, Cursor, Windsurf, Augment, Roo Code)
2. **Automatically configure** the chosen assistant with professional rules and templates
3. **Create project templates** with best practices and documentation standards
4. **Validate environment** and check dependencies before making changes

### **What Gets Configured**

#### **AI Assistant Rules & Guidelines**
Each AI assistant gets configured with its native rule system:

- **GitHub Copilot**: `.github/copilot-instructions.md`, prompt files, and VS Code settings
- **Cline**: `.clinerules/` folder with contextual activation system
- **Cursor**: `.cursor/rules/` with MDC format and auto-attachment
- **Windsurf**: `.windsurf/rules/` with XML formatting and memory integration
- **Augment**: `.augment/rules/` with Always/Manual/Auto activation modes
- **Roo Code**: `.roo/rules/` with hierarchical global/workspace structure

#### **Professional Templates**
- Coding standards and best practices
- Framework-specific guidelines (TypeScript, React, Python, Django, Next.js)
- API development patterns and security practices
- Testing standards with comprehensive examples
- Documentation generation templates
- Code review workflows and checklists

---

## 📋 The Development Methodology

The project also includes a structured development methodology based on requirements-driven design and EARS (Easy Approach to Requirements Syntax):

1.  **Requirements (`src/requirements.md`):** Define *what* the system must do using **User Stories** and **EARS syntax**
2.  **Design (`src/design.md`):** Create a technical blueprint for *how* the system will be built
3.  **Implementation Plan (`src/tasks.md`):** Break the design into actionable tasks with requirement traceability
4.  **Execution:** Follow the structured approach with AI assistant guidance

---

## 🛠️ Detailed Usage

### **Interactive Setup Process**

The setup script provides a user-friendly, interactive experience:

1. **AI Assistant Selection**
   ```
   Which AI coding assistant are you using?
   1) GitHub Copilot
   2) Cline (formerly Claude Dev)
   3) Roo Code
   4) Cursor
   5) Augment
   6) Windsurf
   7) None / Skip AI setup
   ```

2. **Automatic Configuration**
   - Installs necessary extensions (VS Code/Cursor)
   - Creates rule files and directories
   - Sets up templates and examples
   - Configures settings and preferences



### **Advanced Usage with start.sh**

For project scaffolding, use the interactive menu script:

```bash
chmod +x start.sh
./start.sh
```

#### **Option 1: Create a new project**
- Prompts for project name
- Runs `setup.sh` to create structured template
- Sets up documentation, prompts, and source directories

#### **Option 2: Start a task in existing project**
- Prompts for project directory path
- Runs `start_task.sh` for development workflow
- Begins requirements-driven development process

## 📁 Project Structure

The setup script creates a comprehensive development environment with AI assistant configurations:

### **AI Assistant Configurations**
```
project/
├── .github/                     # GitHub Copilot
│   ├── copilot-instructions.md
│   ├── instructions/
│   └── prompts/
├── .clinerules/                 # Cline
│   ├── 01-coding-standards.md
│   ├── 02-documentation.md
│   └── 03-testing-standards.md
├── .cursor/rules/               # Cursor
│   ├── coding-standards.mdc
│   ├── typescript-react.mdc
│   └── api-development.mdc
├── .windsurf/rules/             # Windsurf
│   ├── coding-standards.md
│   ├── typescript-react.md
│   └── api-development.md
├── .augment/rules/              # Augment
│   ├── coding-standards.md
│   ├── typescript-react.md
│   └── testing-standards.md
└── .roo/                        # Roo Code
    ├── rules/
    ├── rules-code/
    ├── rules-docs-extractor/
    ├── rules-architect/
    └── rules-debug/
```

### **Development Templates**
```
project/
├── src/
│   ├── requirements.md         # EARS-based requirements
│   ├── design.md              # Technical specifications
│   └── tasks.md               # Implementation planning
├── docs/                      # Project documentation
├── prompts/                   # Development workflow prompts
└── *-rules-bank/             # Additional rule templates
```

### **Rule Banks for Easy Management**
Each AI assistant gets a rules bank for easy activation:
- `clinerules-bank/` - Cline rule templates
- `cursor-rules-bank/` - Cursor rule templates
- `windsurf-rules-bank/` - Windsurf rule templates
- `augment-rules-bank/` - Augment rule templates
- `roo-rules-bank/` - Roo Code rule templates

### **Legacy Project Structure (start.sh)**
```
my-new-project/
├── .gdn/                   # General coding standards and instructions
├── docs/                   # Project documentation
│   ├── instructions.md     # High-level instructions for the AI
│   ├── requirements.md     # The project's requirements (what to build)
│   └── design.md           # The technical design (how to build it)
├── prompts/                # Step-by-step prompts for the AI
│   └── 01-phase-one-setup.md
├── src/                    # Application source code
├── master_plan.md          # The phased implementation plan (the to-do list)
└── package.json
```

---

## 🎨 AI Assistant Features Breakdown

### **GitHub Copilot Configuration**
- ✅ **Instructions Files** - Custom coding standards and project guidelines
- ✅ **Prompt Files** - Reusable prompts for code review and test generation
- ✅ **VS Code Integration** - Automatic extension installation and settings
- ✅ **File-Specific Rules** - Different instructions for TypeScript, Python, etc.
- ✅ **Commit Message Templates** - Conventional commit format automation

### **Cline (Claude Dev) Configuration**
- ✅ **Rules System** - `.clinerules/` folder with contextual activation
- ✅ **Rules Bank** - Repository of framework and context-specific rules
- ✅ **Contextual Switching** - Easy activation of relevant rules per project phase
- ✅ **Team Collaboration** - Version-controlled rules for consistent standards
- ✅ **Comprehensive Templates** - Coding, testing, documentation, and debugging rules

### **Cursor Configuration**
- ✅ **MDC Format Rules** - Metadata + content format with frontmatter
- ✅ **Auto-Attachment** - Rules automatically apply based on file patterns
- ✅ **Template Integration** - Referenced template files for components and APIs
- ✅ **Multiple Rule Types** - Always, Auto Attached, Agent Requested, Manual
- ✅ **Nested Rules Support** - Subdirectory-specific rule organization

### **Windsurf Configuration**
- ✅ **Memory Integration** - Works with Windsurf's automatic memory system
- ✅ **XML Tag Formatting** - Structured rules for better AI understanding
- ✅ **Four Activation Modes** - Manual, Always On, Model Decision, Glob patterns
- ✅ **Global + Workspace Rules** - Organization and project-specific standards
- ✅ **Template Embedding** - Code examples directly in rules

### **Augment Configuration**
- ✅ **Three Rule Types** - Always, Manual, Auto for different use cases
- ✅ **Migration Support** - Import rules from other AI tools and memories
- ✅ **User Guidelines** - IDE-level preferences across all workspaces
- ✅ **Smart Detection** - Agent automatically applies relevant rules
- ✅ **Legacy Support** - Backward compatibility with existing setups

### **Roo Code Configuration**
- ✅ **Hierarchical Rules** - Global → Workspace → Legacy loading order
- ✅ **Mode-Specific Rules** - Different rules for code, docs, architect, debug modes
- ✅ **Directory Organization** - Better structure than single-file approaches
- ✅ **Override Capability** - Project rules can override global standards
- ✅ **Team Standardization** - Organization-wide consistency with project flexibility

---

## 🚀 Advanced Features

### **Professional Development Templates**
- **Requirements Documentation** - EARS syntax and user story templates
- **Technical Design** - Architecture patterns and component specifications
- **Testing Standards** - Unit, integration, and E2E testing guidelines
- **Security Best Practices** - Input validation, authentication, data protection
- **API Development** - RESTful design, validation, error handling patterns
- **Framework Guidelines** - React, TypeScript, Python, Django, Next.js specific rules

### **Team Collaboration Features**
- **Version-Controlled Rules** - All configurations stored in repository
- **Consistent Standards** - Same rules applied across all team members
- **Easy Rule Management** - Rules banks for quick activation/deactivation
- **Project Customization** - Override global rules with project-specific needs
- **Migration Tools** - Import existing rules from other AI assistants



---

## 🔧 Behind the Scenes

### **Script Architecture**
The project includes multiple scripts for different use cases:

- **`setup.sh`** - Main AI assistant configuration script (v2.0, recommended)
- **`start.sh`** - Legacy project scaffolding script
- **`start_task.sh`** - Interactive requirements-driven development workflow

### **Enhanced Script Features (v2.0)**
- **Strict Mode** - Uses `set -euo pipefail` for safer script execution
- **Signal Handling** - Proper cleanup on interruption with trap handlers
- **Dependency Validation** - Automatic checking of required tools and versions
- **Error Recovery** - Comprehensive error handling with informative messages
- **Dry-Run Mode** - Preview all changes before applying them
- **Command Line Interface** - Full CLI support with help, version, and options
- **Cross-Platform** - Improved portability with `#!/usr/bin/env bash`
- **Professional Output** - Color-coded messages with terminal detection

### **Extensibility**
- **Modular Design** - Easy to add new AI assistants or modify existing ones
- **Template System** - Customizable templates for different project types
- **Rule Banks** - Organized collections of rules for easy management
- **Configuration Detection** - Automatic detection of installed AI assistants
- **Robust Testing** - Built-in validation and testing capabilities

---

## 📋 Requirements

### **System Requirements**
- **Bash 4.0+** - The script automatically validates your Bash version
- **Linux/macOS/Windows** - Cross-platform bash script support with WSL
- **Write Permissions** - Current directory must be writable for configuration files

### **AI Assistant Requirements**
- **VS Code** - Required for most AI assistants (GitHub Copilot, Cline, Augment, Roo Code)
- **Cursor** - Required for Cursor-specific configuration
- **Windsurf** - Required for Windsurf-specific configuration

### **Optional Requirements**
- **Git** - For version control of rules and templates (recommended)
- **curl** - For downloading additional resources (if needed)

### **AI Assistant Extensions**
The script will attempt to install these automatically:
- **GitHub Copilot** - `GitHub.copilot` and `GitHub.copilot-chat`
- **Cline** - `saoudrizwan.claude-dev`
- **Roo Code** - Available from VS Code marketplace
- **Augment** - Available from VS Code marketplace

---

## 🤝 Contributing

### **Adding New AI Assistants**
To add support for a new AI assistant:

1. **Study the Documentation** - Understand the assistant's rule/configuration system
2. **Create Setup Function** - Add a new `setup_[assistant]()` function in `setup.sh`
3. **Follow Patterns** - Use existing implementations as templates
4. **Add to Menu** - Update the assistant selection menu
5. **Test Thoroughly** - Ensure the configuration works as expected

### **Improving Existing Configurations**
- **Update Rule Templates** - Enhance existing rules with better practices
- **Add Framework Support** - Create rules for new frameworks or languages
- **Improve Documentation** - Update README and inline documentation
- **Fix Bugs** - Report and fix any configuration issues

### **Rule Template Contributions**
- **Framework Rules** - Add support for new frameworks (Vue, Angular, Svelte, etc.)
- **Language Rules** - Add support for new languages (Rust, Go, Java, etc.)
- **Workflow Rules** - Add specialized workflow templates (CI/CD, deployment, etc.)
- **Security Rules** - Enhance security best practices and guidelines

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- **AI Assistant Teams** - For creating excellent documentation and rule systems
- **Community Contributors** - For feedback and improvements
- **Open Source Community** - For the tools and frameworks that make this possible

---

## � Troubleshooting

### **Common Issues**

#### **Permission Errors**
```bash
# Make script executable
chmod +x setup.sh

# Check write permissions in current directory
ls -la .
```

#### **Bash Version Issues**
```bash
# Check your Bash version (requires 4.0+)
bash --version

# On macOS, install newer Bash via Homebrew
brew install bash
```

#### **Dependency Issues**
```bash
# Use dry-run to check what would be installed
./setup.sh --dry-run

# Check for missing dependencies
./setup.sh --help  # Shows requirements
```

#### **Script Debugging**
```bash
# Run with verbose output
bash -x ./setup.sh

# Check script syntax
bash -n ./setup.sh

# Use dry-run mode to preview changes
./setup.sh --dry-run --assistant cursor
```

### **Getting Help**
```bash
# Show all available options
./setup.sh --help

# Show version and system information
./setup.sh --version

# Preview changes without applying
./setup.sh --dry-run
```

---

## �📞 Support

- **Issues** - Report bugs or request features via GitHub Issues
- **Discussions** - Join community discussions for questions and ideas
- **Documentation** - Refer to individual AI assistant documentation for specific features
- **Script Help** - Use `./setup.sh --help` for built-in documentation

**Happy Coding with AI! 🚀**