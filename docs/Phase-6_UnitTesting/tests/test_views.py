# core/tests/test_views.py
from django.test import TestCase, Client
from django.urls import reverse
from django.contrib.auth import get_user_model
from core.models import Job

class ViewTests(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = get_user_model().objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            user_type='job_seeker'
        )
        
        # Create employer for job posting tests
        self.employer = get_user_model().objects.create_user(
            username='employer',
            email='employer@example.com',
            password='testpass123',
            user_type='employer',
            company='Test Company'
        )
        
        # Create a test job
        self.job = Job.objects.create(
            employer=self.employer,
            title='Software Engineer',
            company='Test Company',
            location='Remote',
            job_type='full_time',
            description='Test description',
            requirements='Test requirements'
        )
    
    def test_home_view(self):
        """Test home page loads correctly"""
        response = self.client.get(reverse('home'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'core/home.html')
    
    def test_dashboard_requires_login(self):
        """Test dashboard requires authentication"""
        response = self.client.get(reverse('dashboard'))
        self.assertEqual(response.status_code, 302)  # Redirect to login
    
    def test_dashboard_job_seeker(self):
        """Test dashboard for job seeker"""
        self.client.login(username='testuser', password='testpass123')
        response = self.client.get(reverse('dashboard'))
        
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'core/dashboard.html')
        self.assertContains(response, 'Dashboard')