# MCP

## Tools

**MCP servers for PostgreSQL:**

- **[googleapis/genai-toolbox](https://github.com/googleapis/genai-toolbox)**
- **[bytebase/dbhub](https://github.com/bytebase/dbhub)**
- [awslabs/mcp/postgres-mcp-server](https://github.com/awslabs/mcp/tree/main/src/postgres-mcp-server)
- [microsoft/mcp/Azure.Mcp.Tools.Postgres](https://github.com/microsoft/mcp/tree/main/tools/Azure.Mcp.Tools.Postgres/src)
- [Azure-Samples/azure-postgresql-mcp](https://github.com/Azure-Samples/azure-postgresql-mcp)
- [supabase-community/supabase-mcp](https://github.com/supabase-community/supabase-mcp)
- [neondatabase/mcp-server-neon](https://github.com/neondatabase/mcp-server-neon)
- [niledatabase/nile-mcp-server](https://github.com/niledatabase/nile-mcp-server)
- [digitalocean-labs/mcp-digitalocean/dbaas](https://github.com/digitalocean-labs/mcp-digitalocean/blob/main/internal/dbaas/README.md)

**Terminal coding agents with support custom OpenAI-compatible models and MCP:**

- **[sst/opencode](https://github.com/sst/opencode)**
- [continuedev/continue](https://github.com/continuedev/continue)
- [plandex-ai/plandex](https://github.com/plandex-ai/plandex)
- [charmbracelet/crush](https://github.com/charmbracelet/crush)
- [Aider-AI/aider](https://github.com/Aider-AI/aider) (no native support MCP)
    - [hotovo/aider-desk](https://github.com/hotovo/aider-desk)
    - [lutzleonhardt/mcpm-aider](https://github.com/lutzleonhardt/mcpm-aider)

_Not ideal for natural-language-to-SQL. For NL2SQL see:_

- [vanna-ai/vanna](https://github.com/vanna-ai/vanna)
- [Dataherald/dataherald](https://github.com/Dataherald/dataherald)
- [Canner/WrenAI](https://github.com/Canner/WrenAI)
- [defog-ai/sqlcoder](https://github.com/defog-ai/sqlcoder)
- [spiceai/cookbook/text-to-sql](https://github.com/spiceai/cookbook/blob/trunk/text-to-sql/README.md)
- [AlloyDB AI natural language overview](https://cloud.google.com/alloydb/docs/ai/natural-language-overview)

## Example

### Tools

- [Cloud.ru Managed PostgreSQL](https://cloud.ru/products/evolution-managed-postgresql)
- [Cloud.ru Compute](https://cloud.ru/products/evolution-compute)
- MCP server for PostgreSQL:
    - [googleapis/genai-toolbox](https://github.com/googleapis/genai-toolbox)
    - [bytebase/dbhub](https://github.com/bytebase/dbhub)
- AI agent:
    - [Cloud.ru Foundation Models](https://cloud.ru/products/evolution-foundation-models) Qwen3-Coder-480B-A35B-Instruct
    - [sst/opencode](https://github.com/sst/opencode)

### Before you begin

1. Create VM.
2. Create Managed PostgreSQL. Install `pgvector` extension.
3. Create an API key for Foundation Models.
4. Install [Opencode](https://opencode.ai/).
5. Install [MCP Toolbox for Databases](https://github.com/googleapis/genai-toolbox/tree/main)
   and [DBHub](https://github.com/bytebase/dbhub).

### Step 1: Configure Opencode AI Agent

Edit `~/.config/opencode/opencode.json`.

1\. Set up model provider:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "Cloud.ru Foundation Models": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Cloud.ru Foundation Models",
      "options": {
        "baseURL": "https://foundation-models.api.cloud.ru/v1",
        "apiKey": "{env:OPENAI_API_KEY}"
      },
      "models": {
        "Qwen/Qwen3-Coder-480B-A35B-Instruct": {},
        "openai/gpt-oss-120b": {},
        "zai-org/GLM-4.5": {}
      }
    }
  }
}
```

2\. Add MCP servers:

Replace `<POSTGRES_PASSWORD>`.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    ...
  },
  "mcp": {
    "postgres": {
      "type": "local",
      "enabled": true,
      "command": [
        "toolbox",
        "--prebuilt",
        "postgres",
        "--stdio"
      ],
      "environment": {
        "POSTGRES_HOST": "127.0.0.1",
        "POSTGRES_PORT": "15432",
        "POSTGRES_DATABASE": "storeai",
        "POSTGRES_USER": "dbadmin",
        "POSTGRES_PASSWORD": "<POSTGRES_PASSWORD>"
      }
    },
    "dbhub-postgres": {
      "type": "local",
      "enabled": true,
      "command": [
        "npx",
        "-y",
        "@bytebase/dbhub",
        "--transport",
        "stdio",
        "--dsn",
        "postgres://dbadmin:<POSTGRES_PASSWORD>@127.0.0.1:15432/storeai"
      ]
    }
  }
}
```

### Step 2: Set up database

1\. Create tables using the following commands:

```sql
CREATE TABLE products
(
    product_id  SERIAL PRIMARY KEY,
    name        VARCHAR(255)   NOT NULL,
    description TEXT,
    price       DECIMAL(10, 2) NOT NULL,
    category_id INT,
    embedding   vector(3) -- TODO: create embeddings with extension
);

CREATE TABLE customers
(
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR(255)        NOT NULL,
    email       VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE cart
(
    cart_id     SERIAL PRIMARY KEY,
    customer_id INT UNIQUE NOT NULL,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);

CREATE TABLE cart_items
(
    cart_item_id SERIAL PRIMARY KEY,
    cart_id      INT            NOT NULL,
    product_id   INT            NOT NULL,
    quantity     INT            NOT NULL,
    price        DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES cart (cart_id),
    FOREIGN KEY (product_id) REFERENCES products (product_id)
);

CREATE TABLE categories
(
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL
);
```

2\. Insert sample data into the tables:

```sql
INSERT INTO categories (category_id, name)
VALUES (1, 'Flowers'),
       (2, 'Vases');

INSERT INTO products (product_id, name, description, price, category_id, embedding)
VALUES (1, 'Rose', 'A beautiful red rose', 2.50, 1, '[1,2,3]'),
       (2, 'Tulip', 'A colorful tulip', 1.50, 1, '[1,2,3]'),
       (3, 'Glass Vase', 'A transparent glass vase', 10.00, 2, '[1,2,3]'),
       (4, 'Ceramic Vase', 'A handmade ceramic vase', 15.00, 2, '[1,2,3]');

INSERT INTO customers (customer_id, name, email)
VALUES (1, 'John Doe', 'john.doe@example.com'),
       (2, 'Jane Smith', 'jane.smith@example.com');

INSERT INTO cart (cart_id, customer_id)
VALUES (1, 1),
       (2, 2);

INSERT INTO cart_items (cart_id, product_id, quantity, price)
VALUES (1, 1, 2, 2.50),
       (1, 3, 1, 10.00),
       (2, 2, 5, 1.50);
```

### Step 3: Use the AI agent with the database

Replace `<VM_PUBLIC_IP>`. NO COMMENTS 😭

```shell
ssh -N -L 15432:10.0.0.7:5432 -i ~/.ssh/cloudru user1@<VM_PUBLIC_IP> \
  -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3
```

Run Opencode and pick the Qwen3-Coder-480B-A35B-Instruct model:

```shell
opencode
/models
```

**Q:**

```text
Describe storeai database schema
```

**A:**

```text
> I'll help you understand the storeai database schema. Let me first check if there's a database connection available and examine the schema.
> 
> Postgres_list_tables
> ...

# StoreAI Database Schema

The StoreAI database consists of 5 main tables:

## 1. Categories Table

• category_id (integer, primary key): Unique identifier for each category
• name (varchar(255)): Name of the category

## 2. Customers Table

• customer_id (integer, primary key): Unique identifier for each customer
• name (varchar(255)): Customer's name
• email (varchar(255), unique): Customer's email address

## 3. Products Table

• product_id (integer, primary key): Unique identifier for each product
• name (varchar(255)): Product name
• description (text): Detailed product description (optional)
• price (numeric(10,2)): Product price
• category_id (integer): Foreign key linking to categories table (optional)
• embedding (vector(3)): Vector embedding for AI-powered similarity searches

## 4. Cart Table

• cart_id (integer, primary key): Unique identifier for each shopping cart
• customer_id (integer, unique): Foreign key linking to customers table
• created_at (timestamp with time zone): When the cart was created

## 5. Cart Items Table

• cart_item_id (integer, primary key): Unique identifier for each cart item
• cart_id (integer): Foreign key linking to cart table
• product_id (integer): Foreign key linking to products table
• quantity (integer): Number of items
• price (numeric(10,2)): Price of the item at time of addition to cart

The schema supports a basic e-commerce system with customer management, product catalog, and shopping cart functionality, enhanced with AI capabilities through the vector embeddings in the products table.
```

**Q:**

```text
List items in customer cart with cart_id=1
```

**A:**

```text
> I'll help you list the items in the customer cart with cart_id=1. Let me query the database to get this information.
> 
> Postgres_execute_sql SELECT ci.cart_item_id, p.name AS product_name, ci.quantity, ci.price
> FROM cart_items ci
> JOIN products p ON ci.product_id = p.product_id
> WHERE ci.cart_id = 1
> 
> {"cart_item_id":1,"price":2.50,"product_name":"Rose","quantity":2}
> {"cart_item_id":2,"price":10.00,"product_name":"Glass Vase","quantity":1}

# Items in Customer Cart (cart_id=1)

1. Rose
 • Quantity: 2
 • Price: $2.50 per item
 • Cart Item ID: 1
2. Glass Vase
 • Quantity: 1
 • Price: $10.00 per item
 • Cart Item ID: 2

Total items in cart: 2 Total quantity: 3 items
```

**Q:**

```text
List items in cart_id=1 with product name, quantity, item total, and key product/cart info.
```

**A:**

```text
> I'll provide detailed information about the items in customer cart with cart_id=1, including product details and cart information.
> First, let me get the cart details along with customer information:
> Now, let me get the detailed information about items in this cart:
> Let me also get the category information for these products:

# Detailed Cart Information (cart_id=1)

## Cart Details

• Cart ID: 1
• Created At: 2025-09-15T03:18:32.772532+03:00
• Customer: John Doe (ID: 1)
• Email: john.doe@example.com mailto:john.doe@example.com

## Cart Items

### Item 1

• Cart Item ID: 1
• Product ID: 1
• Product Name: Rose
• Category: Flowers
• Description: A beautiful red rose
• Quantity: 2
• Unit Price: $2.50
• Item Total: $5.00

### Item 2

• Cart Item ID: 2
• Product ID: 3
• Product Name: Glass Vase
• Category: Vases
• Description: A transparent glass vase
• Quantity: 1
• Unit Price: $10.00
• Item Total: $10.00

## Cart Summary

• Total Items: 2
• Total Quantity: 3
• Grand Total: $15.00
```
