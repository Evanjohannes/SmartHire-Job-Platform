# core/tests/test_models.py
from django.test import TestCase
from django.contrib.auth import get_user_model
from core.models import Skill, Experience, Education, Job

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
    
    def test_skill_creation(self):
        """Test skill creation"""
        skill = Skill.objects.create(
            user=self.user,
            name='Python',
            proficiency=80
        )
        
        self.assertEqual(skill.name, 'Python')
        self.assertEqual(skill.proficiency, 80)
        self.assertEqual(str(skill), 'Python')
    
    def test_experience_creation(self):
        """Test experience creation"""
        experience = Experience.objects.create(
            user=self.user,
            title='Software Developer',
            company='Tech Corp',
            start_date='2020-01-01'
        )
        
        self.assertEqual(experience.title, 'Software Developer')
        self.assertEqual(str(experience), 'Software Developer at Tech Corp')
    
    def test_education_creation(self):
        """Test education creation"""
        education = Education.objects.create(
            user=self.user,
            degree='Bachelor of Science',
            institution='University',
            start_date='2016-01-01'
        )
        
        self.assertEqual(education.degree, 'Bachelor of Science')
        self.assertEqual(str(education), 'Bachelor of Science - University')