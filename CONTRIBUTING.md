# 🤝 Contributing to Health Monitoring Dashboard

First off, thank you for considering contributing to this project! Every contribution helps make this project better. 🎉

---

## 📋 Table of Contents

- [Code of Conduct](#-code-of-conduct)
- [How Can I Contribute?](#-how-can-i-contribute)
- [Getting Started](#-getting-started)
- [Development Workflow](#-development-workflow)
- [Code Style](#-code-style)
- [Commit Message Format](#-commit-message-format)
- [Pull Request Process](#-pull-request-process)
- [Reporting Bugs](#-reporting-bugs)
- [Suggesting Features](#-suggesting-features)

---

## 📜 Code of Conduct

Please be respectful and constructive in all interactions. We are all here to learn and grow.

---

## 💡 How Can I Contribute?

There are many ways to contribute:

- 🐛 **Report bugs** — Found something broken? Open an issue!
- 💡 **Suggest features** — Have an idea? We'd love to hear it!
- 📖 **Improve documentation** — Typos, unclear instructions, missing guides
- 🧪 **Add tests** — More tests = more confidence
- 🔧 **Fix bugs** — Check open issues and pick one
- ✨ **Add features** — Implement something new

---

## 🚀 Getting Started

### 1️⃣ Fork the Repository

Click the **Fork** button at the top right of the [repository page](https://github.com/zaburdaev/my-devops-project).

### 2️⃣ Clone Your Fork

```bash
git clone https://github.com/YOUR_USERNAME/my-devops-project.git
cd my-devops-project
```

### 3️⃣ Set Up the Development Environment

```bash
# Copy environment file
cp .env.example .env

# Start services
docker-compose up -d --build

# Install Python dependencies (for local testing)
pip install -r requirements.txt
```

### 4️⃣ Create a Branch

```bash
git checkout -b feature/your-feature-name
```

---

## 🔄 Development Workflow

1. **Create a branch** from `main`
2. **Make your changes** in the branch
3. **Write or update tests** if applicable
4. **Run tests** to make sure everything works
5. **Commit** your changes with a clear message
6. **Push** to your fork
7. **Open a Pull Request** against `main`

---

## 🎨 Code Style

### Python

- Follow [PEP 8](https://peps.python.org/pep-0008/) style guide
- Use meaningful variable and function names
- Add docstrings to functions and classes
- Maximum line length: 120 characters
- Use type hints where possible

```python
# ✅ Good
def get_system_metrics() -> dict:
    """Collect and return current system metrics."""
    cpu_usage = psutil.cpu_percent(interval=1)
    return {"cpu_percent": cpu_usage}

# ❌ Bad
def get():
    c = psutil.cpu_percent(1)
    return {"c": c}
```

### Linting

We use `flake8` for Python linting:

```bash
# Run linter
make lint

# Or directly
flake8 app/ tests/ --max-line-length=120
```

### Docker

- Use multi-stage builds when possible
- Run containers as non-root users
- Include health checks
- Use specific image tags (not `latest` for base images)

### Documentation

- Use Markdown for all docs
- Include code examples
- Use emojis for visual structure
- Explain **WHY**, not just **HOW**

---

## 📝 Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <short description>

<optional body>

<optional footer>
```

### Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation changes |
| `style` | Code style changes (formatting, no logic change) |
| `refactor` | Code refactoring |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks |
| `ci` | CI/CD changes |

### Examples

```bash
git commit -m "feat(api): add /api/disk-info endpoint"
git commit -m "fix(cache): resolve Redis connection timeout"
git commit -m "docs: update GETTING_STARTED.md with troubleshooting"
git commit -m "test: add unit tests for metrics caching"
git commit -m "ci: add code coverage reporting to pipeline"
```

---

## 🔀 Pull Request Process

### Before Submitting

- [ ] Tests pass locally (`make test`)
- [ ] Linting passes (`make lint`)
- [ ] Documentation is updated if needed
- [ ] Commit messages follow the convention
- [ ] Branch is up to date with `main`

### PR Title

Use the same format as commit messages:

```
feat(monitoring): add disk I/O metrics panel to Grafana
```

### PR Description

Include:
- **What** changed
- **Why** the change was made
- **How** to test the change
- Screenshots (if UI changes)

### Review Process

1. A maintainer will review your PR
2. They may request changes — this is normal and helpful!
3. Once approved, the PR will be merged
4. Your contribution will be part of the project! 🎉

---

## 🐛 Reporting Bugs

When reporting a bug, please include:

1. **Description** — What happened?
2. **Steps to reproduce** — How can we recreate the issue?
3. **Expected behavior** — What should have happened?
4. **Actual behavior** — What actually happened?
5. **Environment** — OS, Docker version, browser, etc.
6. **Screenshots/Logs** — If applicable

---

## 💡 Suggesting Features

When suggesting a feature, please include:

1. **Problem** — What problem does this solve?
2. **Solution** — What's your proposed solution?
3. **Alternatives** — Have you considered other approaches?
4. **Additional context** — Anything else we should know?

---

## 🙏 Thank You!

Every contribution, no matter how small, makes a difference. Thank you for helping improve this project! ❤️

---

<p align="center">
  Made with ❤️ by <strong>Vitalii Zaburdaiev</strong> | DevOpsUA6
</p>
