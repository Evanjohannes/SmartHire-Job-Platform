# core/tests/test_tdd_example.py
from django.test import TestCase
from django.urls import reverse
from django.contrib.auth import get_user_model

class TDDExampleTests(TestCase):
    """
    Example of Test-Driven Development workflow
    """
    
    def setUp(self):
        """Set up test data"""
        self.user = get_user_model().objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            user_type='job_seeker'
        )
    
    def test_profile_completion(self):
        """Test profile completion logic"""
        # Initially profile should be incomplete
        self.assertFalse(self.user.has_complete_profile)
        
        # Add some data
        self.user.bio = 'Test bio'
        self.user.location = 'Test City'
        self.user.save()
        
        # Profile should still be incomplete without skills/experience
        self.assertFalse(self.user.has_complete_profile)
    
    def test_home_page_access(self):
        """Test home page accessibility"""
        response = self.client.get(reverse('home'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'Jobify')