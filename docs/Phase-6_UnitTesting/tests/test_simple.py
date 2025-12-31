# core/tests/test_simple.py
from django.test import TestCase

class SimpleTests(TestCase):
    """Simple tests to verify test setup is working"""
    
    def test_addition(self):
        """Test basic addition"""
        self.assertEqual(1 + 1, 2)
    
    def test_true_is_true(self):
        """Test boolean logic"""
        self.assertTrue(True)
        self.assertFalse(False)
    
    def test_string_concatenation(self):
        """Test string operations"""
        result = "Hello" + " " + "World"
        self.assertEqual(result, "Hello World")