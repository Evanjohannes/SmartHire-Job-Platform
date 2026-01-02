# Jobify - Actors

## Primary Actors:

1. **Job Seeker**

   - Description: Individuals looking for employment opportunities

   - Role: Create profile, search jobs, apply, track applications, build CV

   - Authentication: Registered user with job_seeker role

2. **Employer**

   - Description: Companies/recruiters looking to hire candidates

   - Role: Post jobs, review applications, schedule interviews, manage candidates

   - Authentication: Registered user with employer role

3. **Admin**
   - Description: System administrator
   - Goals: Manage users, monitor system, resolve issues

## Secondary/External Actors:

4. **Payment System** (External)

   - Description: External payment gateway
   - Role: Process subscription payments

5. **Email Service** (External)

   - Description: External email provider
   - Role: Send notifications and alerts

6. **Calendar Service** (External)
   - Description: External calendar APIs
   - Role: Schedule and sync interviews
