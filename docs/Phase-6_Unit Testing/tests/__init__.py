from django.test import TestCase
from django.contrib.auth import get_user_model
from core.models import *

class ModelTests(TestCase):
    def setUp(self):
        """Set up test data that will be used in multiple tests"""
        self.user = get_user_model().objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            user_type='job_seeker'
        )
    
    def test_user_creation(self):
        """Test user model creation"""
        self.assertEqual(self.user.username, 'testuser')
        self.assertEqual(self.user.email, 'test@example.com')
        self.assertTrue(self.user.is_job_seeker)
        self.assertFalse(self.user.is_employer)
    
    def test_job_seeker_full_name(self):
        """Test full_name property"""
        self.user.first_name = 'John'
        self.user.last_name = 'Doe'
        self.user.save()
        
        self.assertEqual(self.user.full_name, 'John Doe')
    
    def test_has_complete_profile_job_seeker(self):
        """Test profile completeness for job seeker"""
        # Initially should be incomplete
        self.assertFalse(self.user.has_complete_profile)
        
        # Add required fields
        self.user.bio = 'Test bio'
        self.user.location = 'Test City'
        self.user.save()
        
        # Add skills
        Skill.objects.create(user=self.user, name='Python', proficiency=80)
        
        # Add experience
        Experience.objects.create(
            user=self.user,
            title='Developer',
            company='Test Company',
            start_date='2020-01-01'
        )
        
        # Add education
        Education.objects.create(
            user=self.user,
            degree='Bachelor',
            institution='Test University',
            start_date='2016-01-01'
        )
        
        # Still incomplete without resume
        self.assertFalse(self.user.has_complete_profile)
    
    def test_job_creation(self):
        """Test job model creation"""
        employer = get_user_model().objects.create_user(
            username='employer',
            email='employer@example.com',
            password='testpass123',
            user_type='employer',
            company='Test Company'
        )
        
        job = Job.objects.create(
            employer=employer,
            title='Software Engineer',
            company='Test Company',
            location='Remote',
            job_type='full_time',
            description='Test description',
            requirements='Test requirements'
        )
        
        self.assertEqual(str(job), 'Software Engineer at Test Company')
        self.assertTrue(job.is_active)
    
    def test_job_application_unique_together(self):
        """Test unique constraint on job applications"""
        employer = get_user_model().objects.create_user(
            username='employer1',
            email='employer1@example.com',
            password='testpass123',
            user_type='employer'
        )
        
        job = Job.objects.create(
            employer=employer,
            title='Test Job',
            company='Test Co',
            location='Remote',
            description='Test',
            requirements='Test'
        )
        
        # First application should work
        JobApplication.objects.create(job=job, applicant=self.user)
        
        # Second application should fail due to unique constraint
        with self.assertRaises(Exception):
            JobApplication.objects.create(job=job, applicant=self.user)