from django.test import TestCase
from django.urls import reverse, resolve
from core import views

class URLTests(TestCase):
    def test_home_url(self):
        """Test home URL resolves to correct view"""
        url = reverse('home')
        self.assertEqual(resolve(url).func, views.home)
    
    def test_register_url(self):
        """Test register URL"""
        url = reverse('register')
        self.assertEqual(resolve(url).func, views.register)
    
    def test_dashboard_url(self):
        """Test dashboard URL"""
        url = reverse('dashboard')
        self.assertEqual(resolve(url).func, views.dashboard)
    
    def test_profile_url(self):
        """Test profile URL"""
        url = reverse('profile')
        self.assertEqual(resolve(url).func, views.profile)
    
    def test_job_list_url(self):
        """Test job list URL"""
        url = reverse('job_list')
        self.assertEqual(resolve(url).func, views.job_list)
    
    def test_job_detail_url(self):
        """Test job detail URL"""
        url = reverse('job_detail', args=[1])
        self.assertEqual(resolve(url).func, views.job_detail)
    
    def test_cv_builder_url(self):
        """Test CV builder URL"""
        url = reverse('cv_builder')
        self.assertEqual(resolve(url).func, views.cv_builder)
    
    def test_messages_url(self):
        """Test messages URL"""
        url = reverse('messages_list')
        self.assertEqual(resolve(url).func, views.messages_list)
    
    def test_interviews_url(self):
        """Test interviews URL"""
        url = reverse('interviews_list')
        self.assertEqual(resolve(url).func, views.interviews_list)
    
    def test_chatbot_url(self):
        """Test chatbot URL"""
        url = reverse('chatbot')
        self.assertEqual(resolve(url).func, views.chatbot)