#!/usr/bin/env python3.12
"""
Test script for AI Development Environment
Verifies that all major components are working correctly.
"""

import sys
import subprocess
import importlib.util
from pathlib import Path


def check_python_version():
    """Check Python version"""
    print("🐍 Python Version Check")
    print(f"   Python version: {sys.version}")
    if sys.version_info >= (3, 12):
        print("   ✅ Python 3.12+ is available")
        return True
    else:
        print("   ❌ Python 3.12+ is required")
        return False


def check_package(package_name, import_name=None):
    """Check if a package is installed and importable"""
    if import_name is None:
        import_name = package_name
    
    try:
        spec = importlib.util.find_spec(import_name)
        if spec is not None:
            module = importlib.import_module(import_name)
            version = getattr(module, '__version__', 'unknown')
            print(f"   ✅ {package_name} ({version})")
            return True
        else:
            print(f"   ❌ {package_name} not found")
            return False
    except ImportError as e:
        print(f"   ❌ {package_name} import error: {e}")
        return False


def check_cuda():
    """Check CUDA availability"""
    print("\n🚀 CUDA Check")
    
    # Check nvidia-smi
    try:
        result = subprocess.run(['nvidia-smi'], capture_output=True, text=True)
        if result.returncode == 0:
            print("   ✅ nvidia-smi is available")
        else:
            print("   ❌ nvidia-smi failed")
            return False
    except FileNotFoundError:
        print("   ❌ nvidia-smi not found")
        return False
    
    # Check PyTorch CUDA
    try:
        import torch
        if torch.cuda.is_available():
            print(f"   ✅ PyTorch CUDA is available")
            print(f"   🎮 GPU count: {torch.cuda.device_count()}")
            if torch.cuda.device_count() > 0:
                print(f"   🎮 GPU name: {torch.cuda.get_device_name(0)}")
            return True
        else:
            print("   ❌ PyTorch CUDA is not available")
            return False
    except ImportError:
        print("   ❌ PyTorch not installed")
        return False


def check_tensorflow_gpu():
    """Check TensorFlow GPU availability"""
    print("\n🧠 TensorFlow GPU Check")
    try:
        import tensorflow as tf
        gpus = tf.config.experimental.list_physical_devices('GPU')
        if gpus:
            print(f"   ✅ TensorFlow GPU is available")
            print(f"   🎮 GPU count: {len(gpus)}")
            return True
        else:
            print("   ❌ TensorFlow GPU is not available")
            return False
    except ImportError:
        print("   ❌ TensorFlow not installed")
        return False


def check_ai_packages():
    """Check AI/ML packages"""
    print("\n🤖 AI/ML Packages Check")
    
    packages = [
        ('torch', 'torch'),
        ('torchvision', 'torchvision'),
        ('tensorflow', 'tensorflow'),
        ('transformers', 'transformers'),
        ('numpy', 'numpy'),
        ('pandas', 'pandas'),
        ('scikit-learn', 'sklearn'),
        ('matplotlib', 'matplotlib'),
        ('seaborn', 'seaborn'),
        ('opencv-python', 'cv2'),
        ('pillow', 'PIL'),
        ('jupyter', 'jupyter'),
        ('fastapi', 'fastapi'),
        ('gradio', 'gradio'),
        ('streamlit', 'streamlit'),
        ('langchain', 'langchain'),
    ]
    
    success_count = 0
    total_count = len(packages)
    
    for package_name, import_name in packages:
        if check_package(package_name, import_name):
            success_count += 1
    
    print(f"\n   📊 Packages: {success_count}/{total_count} available")
    return success_count == total_count


def check_development_tools():
    """Check development tools"""
    print("\n🛠️ Development Tools Check")
    
    tools = [
        ('git', 'git --version'),
        ('vim', 'vim --version'),
        ('zsh', 'zsh --version'),
        ('docker', 'docker --version'),
        ('cmake', 'cmake --version'),
        ('make', 'make --version'),
        ('gcc', 'gcc --version'),
        ('python', 'python --version'),
        ('pip', 'pip --version'),
    ]
    
    success_count = 0
    total_count = len(tools)
    
    for tool_name, command in tools:
        try:
            result = subprocess.run(command.split(), capture_output=True, text=True)
            if result.returncode == 0:
                version_line = result.stdout.split('\n')[0]
                print(f"   ✅ {tool_name}: {version_line}")
                success_count += 1
            else:
                print(f"   ❌ {tool_name}: command failed")
        except FileNotFoundError:
            print(f"   ❌ {tool_name}: not found")
    
    print(f"\n   📊 Tools: {success_count}/{total_count} available")
    return success_count == total_count


def check_environment():
    """Check environment variables"""
    print("\n🌍 Environment Variables Check")
    
    env_vars = [
        'CUDA_HOME',
        'PATH',
        'LD_LIBRARY_PATH',
        'PYTHONPATH',
    ]
    
    import os
    for var in env_vars:
        value = os.environ.get(var)
        if value:
            print(f"   ✅ {var}: {value[:50]}{'...' if len(value) > 50 else ''}")
        else:
            print(f"   ❌ {var}: not set")


def main():
    """Main test function"""
    print("🤖 AI Development Environment Test")
    print("=" * 50)
    
    all_tests = [
        check_python_version(),
        check_cuda(),
        check_tensorflow_gpu(),
        check_ai_packages(),
        check_development_tools(),
    ]
    
    check_environment()
    
    print("\n" + "=" * 50)
    print("📊 Test Summary")
    
    passed = sum(all_tests)
    total = len(all_tests)
    
    if passed == total:
        print(f"   🎉 All tests passed! ({passed}/{total})")
        print("   🚀 Your AI development environment is ready!")
    else:
        print(f"   ⚠️  Some tests failed ({passed}/{total})")
        print("   🔧 Please check the failed components above")
    
    return passed == total


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)