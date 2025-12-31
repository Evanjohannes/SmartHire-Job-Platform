# core/tests/test_forms.py
from django.test import TestCase
from core.forms import RegistrationForm, JobSeekerProfileForm, EmployerProfileForm
from django.contrib.auth import get_user_model

class FormTests(TestCase):
    def test_registration_form_valid(self):
        """Test registration form with valid data"""
        form_data = {
            'username': 'newuser',
            'email': 'new@example.com',
            'user_type': 'job_seeker',
            'password1': 'complexpass123',
            'password2': 'complexpass123'
        }
        
        form = RegistrationForm(data=form_data)
        self.assertTrue(form.is_valid())
    
    def test_registration_form_invalid(self):
        """Test registration form with invalid data"""
        # Passwords don't match
        form_data = {
            'username': 'newuser',
            'email': 'new@example.com',
            'user_type': 'job_seeker',
            'password1': 'complexpass123',
            'password2': 'differentpass'
        }
        
        form = RegistrationForm(data=form_data)
        self.assertFalse(form.is_valid())
        self.assertIn('password2', form.errors)
    
    def test_job_seeker_profile_form(self):
        """Test job seeker profile form"""
        user = get_user_model().objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            user_type='job_seeker'
        )
        
        form_data = {
            'first_name': 'John',
            'last_name': 'Doe',
            'email': 'john.doe@example.com',
            'phone': '1234567890',
            'bio': 'Experienced developer',
            'location': 'New York'
        }
        
        form = JobSeekerProfileForm(data=form_data, instance=user)
        self.assertTrue(form.is_valid())