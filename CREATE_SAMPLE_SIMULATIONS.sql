-- ============================================================================
-- INSERT SAMPLE SIMULATIONS WITH TASKS
-- ============================================================================

-- 🟢 SIMULATION 1: E-Commerce Platform Development
INSERT INTO simulations (title, description, category, difficulty, duration, image, overview, features, skills, rating)
VALUES (
  'E-Commerce Platform Development',
  'Build a complete e-commerce platform with product management, shopping cart, payment processing, and order tracking.',
  'Software Development',
  'Advanced',
  '4-6 weeks',
  'https://images.unsplash.com/photo-1460925895917-adf4e565f900?w=500&h=300',
  'Create a full-stack e-commerce solution with modern web technologies. Learn to handle complex business logic, database design, and payment integrations.',
  'Product Catalog, Shopping Cart, User Authentication, Payment Gateway Integration (Stripe), Order Management, Inventory System, Admin Dashboard',
  'React, Node.js, MongoDB, Express, Stripe API, Redux',
  4.8
);

-- Get the ID of the first simulation
WITH sim1 AS (
  SELECT id FROM simulations WHERE title = 'E-Commerce Platform Development' LIMIT 1
)
INSERT INTO tasks (simulation_id, title, full_title, duration, difficulty, description, what_youll_learn, what_youll_do, material_url)
VALUES
(
  (SELECT id FROM sim1),
  'Task One',
  'Setup Project Architecture',
  '1-2 hours',
  'Beginner',
  'Initialize the project repository and set up the development environment with all necessary tools and configurations.',
  'Project structure best practices, environment setup, Git workflow, development tools configuration',
  'Clone repository, install dependencies, configure environment variables, set up database connection, create initial project structure',
  NULL
),
(
  (SELECT id FROM sim1),
  'Task Two',
  'Design Database Schema',
  '2-3 hours',
  'Intermediate',
  'Design and implement the MongoDB schema for products, users, orders, and cart management.',
  'Database design principles, normalization, relationships, indexing strategies',
  'Create collections for Products, Users, Orders, Cart Items; define relationships; set up indexes for performance',
  NULL
),
(
  (SELECT id FROM sim1),
  'Task Three',
  'Implement User Authentication',
  '3-4 hours',
  'Intermediate',
  'Build secure user authentication and authorization system with JWT tokens.',
  'Authentication flows, JWT implementation, password hashing, authorization middleware',
  'Implement signup/login endpoints, JWT token generation, protected routes, role-based access control',
  NULL
),
(
  (SELECT id FROM sim1),
  'Task Four',
  'Build Product Catalog & Search',
  '3-4 hours',
  'Intermediate',
  'Create product listing, filtering, sorting, and search functionality.',
  'REST API design, query optimization, pagination, filtering algorithms',
  'Create product endpoints, implement filtering by category/price/rating, add search functionality, pagination',
  NULL
),
(
  (SELECT id FROM sim1),
  'Task Five',
  'Integrate Payment Processing',
  '4-5 hours',
  'Advanced',
  'Implement Stripe payment gateway integration for secure payment processing.',
  'Payment gateway integration, PCI compliance, transaction handling, error management',
  'Set up Stripe API keys, create payment endpoints, handle payment callbacks, implement transaction logging',
  NULL
);

-- 🟡 SIMULATION 2: Mobile Social Media App
INSERT INTO simulations (title, description, category, difficulty, duration, image, overview, features, skills, rating)
VALUES (
  'Mobile Social Media App Development',
  'Develop a social media application with real-time messaging, user profiles, feed management, and notifications.',
  'Mobile Development',
  'Intermediate',
  '3-4 weeks',
  'https://images.unsplash.com/photo-1512941691920-25bda36cbc3b?w=500&h=300',
  'Build a feature-rich mobile social media application. Master real-time communication, state management, and mobile UI/UX principles.',
  'User Profiles, Social Feed, Real-time Messaging, Notifications, Like/Comment System, User Following/Followers, Image Upload',
  'React Native, Firebase, Redux, Node.js, WebSocket',
  4.6
);

WITH sim2 AS (
  SELECT id FROM simulations WHERE title = 'Mobile Social Media App Development' LIMIT 1
)
INSERT INTO tasks (simulation_id, title, full_title, duration, difficulty, description, what_youll_learn, what_youll_do, material_url)
VALUES
(
  (SELECT id FROM sim2),
  'Task One',
  'Setup React Native Project',
  '45-60 mins',
  'Beginner',
  'Initialize a React Native project with necessary dependencies and project structure.',
  'React Native fundamentals, project scaffolding, dependency management, mobile development workflow',
  'Create React Native project using Expo or React Native CLI, install essential packages, set up navigation',
  NULL
),
(
  (SELECT id FROM sim2),
  'Task Two',
  'Design User Authentication System',
  '2-3 hours',
  'Intermediate',
  'Implement user registration and login with Firebase Authentication.',
  'Firebase authentication, secure credential handling, user session management',
  'Set up Firebase project, implement sign-up/login screens, handle authentication state, token storage',
  NULL
),
(
  (SELECT id FROM sim2),
  'Task Three',
  'Create User Profile Management',
  '2-3 hours',
  'Intermediate',
  'Build user profile pages with profile editing, avatar upload, and profile viewing.',
  'File uploads, image optimization, form handling, user data management',
  'Design profile screen, implement profile editing, add image upload functionality, store user data in Firebase',
  NULL
),
(
  (SELECT id FROM sim2),
  'Task Four',
  'Build Social Feed with Real-time Updates',
  '3-4 hours',
  'Advanced',
  'Create a dynamic social feed with post creation, likes, comments, and real-time updates.',
  'Real-time database listeners, state management with Redux, UI performance optimization',
  'Design feed UI, implement post creation, add like/comment functionality, set up real-time listeners',
  NULL
);

-- 🔵 SIMULATION 3: Data Analytics Dashboard
INSERT INTO simulations (title, description, category, difficulty, duration, image, overview, features, skills, rating)
VALUES (
  'Data Analytics Dashboard Development',
  'Create an interactive data analytics dashboard with charts, reports, data filtering, and real-time analytics.',
  'Data Science & Analytics',
  'Intermediate',
  '2-3 weeks',
  'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500&h=300',
  'Build a comprehensive analytics dashboard with visualization, reporting, and insights. Learn data processing and visualization best practices.',
  'Interactive Charts, Data Filtering, Real-time Reports, Export Functionality, User Analytics, Performance Metrics, Comparative Analysis',
  'React, Chart.js, D3.js, Python (Pandas), SQL, Plotly',
  4.5
);

WITH sim3 AS (
  SELECT id FROM simulations WHERE title = 'Data Analytics Dashboard Development' LIMIT 1
)
INSERT INTO tasks (simulation_id, title, full_title, duration, difficulty, description, what_youll_learn, what_youll_do, material_url)
VALUES
(
  (SELECT id FROM sim3),
  'Task One',
  'Setup Data Pipeline',
  '2-3 hours',
  'Intermediate',
  'Create a backend data pipeline to fetch, process, and store analytics data.',
  'Data pipeline architecture, ETL processes, data cleaning, database optimization',
  'Set up database schema for analytics, create data ingestion scripts, implement data cleaning pipelines',
  NULL
),
(
  (SELECT id FROM sim3),
  'Task Two',
  'Design Dashboard Layout',
  '1-2 hours',
  'Beginner',
  'Create the responsive dashboard layout with multiple widget sections.',
  'Responsive design, component architecture, UI/UX principles for dashboards',
  'Design dashboard grid layout, create reusable widget components, implement responsive design',
  NULL
),
(
  (SELECT id FROM sim3),
  'Task Three',
  'Implement Data Visualizations',
  '3-4 hours',
  'Intermediate',
  'Build interactive charts and graphs for data visualization.',
  'Chart libraries (Chart.js, D3.js), data visualization best practices, interactive charts',
  'Implement line charts, bar graphs, pie charts, heatmaps using Chart.js and D3.js',
  NULL
),
(
  (SELECT id FROM sim3),
  'Task Four',
  'Add Filtering & Export Features',
  '2-3 hours',
  'Intermediate',
  'Implement advanced filtering options and data export functionality.',
  'Advanced filtering algorithms, data export formats (CSV, PDF), query optimization',
  'Build filter UI for date ranges and categories, implement CSV/PDF export, optimize query performance',
  NULL
);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify simulations were created
SELECT COUNT(*) as total_simulations FROM simulations;

-- Verify tasks were created
SELECT s.title, COUNT(t.id) as task_count
FROM simulations s
LEFT JOIN tasks t ON s.id = t.simulation_id
GROUP BY s.id, s.title;
