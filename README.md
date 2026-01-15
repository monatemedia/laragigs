# LaraGigs

**A Laravel-based job board for PHP Laravel developer positions**

[![Laravel](https://img.shields.io/badge/Laravel-9.x-red.svg)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-8.0%2B-blue.svg)](https://php.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🔹 About The Project

LaraGigs is a full-stack job listing platform built with Laravel 9, designed specifically for companies hiring Laravel developers. The application demonstrates core Laravel concepts including authentication, authorization, Eloquent relationships, query scopes, and Blade component architecture.

### Key Features

* **User Authentication** - Registration, login, and session management
* **Job Listings CRUD** - Create, read, update, and delete job postings
* **Image Uploads** - Company logo uploads with Laravel's storage system
* **Search & Filter** - Tag-based and keyword search using Laravel query scopes
* **Authorization** - Ownership-based permissions (users can only edit/delete their own listings)
* **Pagination** - Built-in Laravel pagination for listing pages
* **Flash Messages** - User feedback for actions (create, update, delete)
* **Responsive UI** - Tailwind CSS with Blade component architecture

---

## 🔹 Tech Stack

* **Backend:** Laravel 9.x, PHP 8.0+
* **Database:** MySQL
* **Frontend:** Blade Templates, Tailwind CSS
* **Deployment:** Docker, Docker Compose
* **Authentication:** Laravel's built-in authentication system

---

## 🔹 Getting Started

### Prerequisites

* PHP 8.0 or higher
* Composer
* MySQL 5.7+ or MariaDB
* Node.js & npm (for asset compilation)
* Docker & Docker Compose (for containerized deployment)

### Local Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/monatemedia/laragigs.git
   cd laragigs
   ```

2. **Install PHP dependencies**
   ```bash
   composer install
   ```

3. **Install JavaScript dependencies**
   ```bash
   npm install
   npm run dev
   ```

4. **Create environment file**
   ```bash
   cp .env.example .env
   ```

5. **Configure your database in `.env`**
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=laragigs
   DB_USERNAME=your_username
   DB_PASSWORD=your_password
   ```

6. **Generate application key**
   ```bash
   php artisan key:generate
   ```

7. **Run migrations**
   ```bash
   php artisan migrate
   ```

8. **Seed the database (optional)**
   ```bash
   php artisan db:seed
   ```
   This creates a test user:
   - Email: `john@gmail.com`
   - Password: `password`

9. **Create symbolic link for storage**
   ```bash
   php artisan storage:link
   ```
   Or visit `/linkstorage` in your browser after starting the server.

10. **Start the development server**
    ```bash
    php artisan serve
    ```

11. **Access the application**
    
    Open your browser to: `http://127.0.0.1:8000`

---

## 🔹 Docker Deployment

### Running with Docker Compose

1. **Build and start containers**
   ```bash
   docker-compose up -d
   ```

2. **Run migrations inside the container**
   ```bash
   docker-compose exec app php artisan migrate
   docker-compose exec app php artisan db:seed
   docker-compose exec app php artisan storage:link
   ```

3. **Access the application**
   
   The application will be available at the configured domain in your `docker-compose.yml`

### Stopping Containers

```bash
docker-compose down
```

---

## 🔹 Application Structure

### Database Schema

**Users Table**
- `id` - Primary key
- `name` - User's full name
- `email` - Unique email address
- `password` - Hashed password
- `created_at`, `updated_at` - Timestamps

**Listings Table**
- `id` - Primary key
- `user_id` - Foreign key (references users, cascade on delete)
- `title` - Job title
- `company` - Company name (unique)
- `location` - Job location
- `email` - Contact email
- `website` - Company website
- `tags` - Comma-separated tags
- `description` - Full job description (longText)
- `logo` - Company logo path (nullable)
- `created_at`, `updated_at` - Timestamps

### Routes

| Method | URI | Action | Middleware |
|--------|-----|--------|------------|
| GET | `/` | Show all listings | - |
| GET | `/listings/create` | Show create form | auth |
| POST | `/listings` | Store new listing | auth |
| GET | `/listings/{listing}` | Show single listing | - |
| GET | `/listings/{listing}/edit` | Show edit form | auth |
| PUT | `/listings/{listing}` | Update listing | auth |
| DELETE | `/listings/{listing}` | Delete listing | auth |
| GET | `/listings/manage` | Manage user's listings | auth |
| GET | `/register` | Show registration form | guest |
| POST | `/users` | Register new user | - |
| GET | `/login` | Show login form | guest |
| POST | `/users/authenticate` | Authenticate user | - |
| POST | `/logout` | Log out user | auth |

### Key Laravel Features Demonstrated

**Query Scopes**
```php
// app/Models/Listing.php
public function scopeFilter($query, array $filters) {
    if($filters['tag'] ?? false){
        $query->where('tags', 'like', '%' . request('tag') . '%');
    }
    
    if($filters['search'] ?? false){
        $query->where('title', 'like', '%' . request('search') . '%')
            ->orWhere('description', 'like', '%' . request('search') . '%')
            ->orWhere('tags', 'like', '%' . request('search') . '%');
    }
}
```

**Eloquent Relationships**
```php
// Listing belongs to User
public function user() {
    return $this->belongsTo(User::class, 'user_id');
}
```

**Authorization**
```php
// ListingController.php
if ($listing->user_id != auth()->id()) {
    abort(403, 'Unauthorized Action');
}
```

**Form Validation**
```php
$formFields = $request->validate([
    'title' => 'required',
    'company' => ['required', Rule::unique('listings', 'company')],
    'location' => 'required',
    'website' => 'required',
    'email' => ['required', 'email'],
    'tags' => 'required',
    'description' => 'required'
]);
```

**Blade Components**
```blade
{{-- resources/views/listings/index.blade.php --}}
<x-layout>
    @include('partials._hero')
    @include('partials._search')
    
    @foreach ($listings as $listing)
        <x-listing-card :listing="$listing"/>
    @endforeach
    
    {{ $listings->links() }}
</x-layout>
```

---

## 🔹 Usage

### Creating a Listing

1. Register or log in to your account
2. Click "Post a Gig" in the navigation
3. Fill in the job details:
   - Job title
   - Company name (must be unique)
   - Location
   - Company website
   - Contact email
   - Tags (comma-separated, e.g., "laravel, api, mysql")
   - Description
   - Company logo (optional)
4. Click "Create Gig"

### Managing Your Listings

1. Click "Manage Gigs" in the navigation
2. View all your posted jobs
3. Edit or delete listings as needed

### Searching for Jobs

* Use the search bar on the homepage to search by title, description, or tags
* Click on any tag to filter listings by that technology
* Browse paginated results

---

## 🔹 Demo

**Status:** Offline by default (resource optimization)  
**Available:** On request via Docker Compose

To run the demo on the VPS:
```bash
docker-compose up -d
```

**Test Credentials:**
- Email: `john@gmail.com`
- Password: `password`

---

## 🔹 Development Notes

This project was built as a learning exercise to demonstrate:
- Laravel MVC architecture
- Eloquent ORM and relationships
- Authentication and authorization
- Form validation and file uploads
- Query scopes and filtering
- Blade templating and components
- Database migrations and seeders
- Docker containerization

---

## 🔹 Roadmap

- [ ] Add email verification for new users
- [ ] Implement job application system
- [ ] Add admin dashboard for moderation
- [ ] Implement job expiration dates
- [ ] Add company profiles
- [ ] Email notifications for new listings
- [ ] API endpoints for mobile app
- [ ] Advanced search filters (salary range, remote options)
- [ ] Bookmarking/favoriting listings

---

## 🔹 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 🔹 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 🔹 Contact

Edward Baitsewe  
📧 edward@monatemedia.com  
🔗 [LinkedIn](https://www.linkedin.com/in/edwardbaitsewe)  
🌐 [Portfolio](https://monatemedia.com/portfolio)  
🐙 [GitHub](https://github.com/monatemedia)

**Project Link:** [https://github.com/monatemedia/laragigs](https://github.com/monatemedia/laragigs)

---

## 🔹 Acknowledgments

* [Laravel Documentation](https://laravel.com/docs)
* [Tailwind CSS](https://tailwindcss.com)
* [Traversy Media - Laravel Crash Course](https://www.youtube.com/watch?v=MYyJ4PuL4pY)
* [Laravel Daily - Tips & Tricks](https://laraveldaily.com)
