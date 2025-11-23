# Hướng Dẫn: Azure Databricks và Tích Hợp với Terraform

## PHẦN 1: DATABRICKS LÀ CÁI GÌ?

### 1.1 Định Nghĩa

**Azure Databricks** là một nền tảng phân tích dữ liệu hợp nhất (Unified Analytics Platform) được Microsoft và Databricks phát triển, chạy trên nền tảng Azure. Nó kết hợp sức mạnh của Apache Spark với các công nghệ hiện đại như Delta Lake, MLflow để xử lý dữ liệu lớn và AI/ML.

### 1.2 Databricks Là Gì Dưới Góc Độ Kỹ Thuật?

Databricks = **Apache Spark + Delta Lake + MLflow + Collaboration Tools**

- **Apache Spark**: Engine xử lý dữ liệu phân tán, có thể xử lý hàng tỷ dòng dữ liệu
- **Delta Lake**: Lớp lưu trữ hỗ trợ giao dịch ACID, versioning, time-travel cho data lake
- **MLflow**: Công cụ quản lý vòng đời mô hình Machine Learning
- **Workspace Collaboration**: Giao diện web cho phép nhiều người làm việc cùng lúc

### 1.3 Databricks Được Dùng Để Làm Gì?

| Trường Hợp Sử Dụng        | Mô Tả                                                                             |
| ------------------------- | --------------------------------------------------------------------------------- |
| **Data Lakehouse**        | Kết hợp data lake (lưu trữ thô) + data warehouse (truy vấn mạnh) trong 1 nền tảng |
| **ETL/Data Engineering**  | Xây dựng pipeline xử lý dữ liệu quy mô lớn với Auto Loader                        |
| **Machine Learning & AI** | Training, fine-tuning LLM, deployment mô hình ML                                  |
| **Data Warehousing & BI** | Databricks SQL cho truy vấn tốc độ cao, kết nối Power BI                          |
| **Real-time Streaming**   | Xử lý dữ liệu thời gian thực từ Event Hubs, Kafka                                 |
| **Data Governance**       | Unity Catalog cho kiểm soát truy cập, data lineage, auditing                      |

### 1.4 Kiến Trúc Databricks

```
┌─────────────────────────────────────────┐
│      Databricks Workspace (UI)          │
│  - Notebooks (Python, SQL, Scala, R)    │
│  - Jobs, Workflows                      │
│  - Clusters Management                  │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│    Databricks Control Plane             │
│  - Authentication, Authorization        │
│  - Cluster Orchestration                │
│  - Job Scheduling                       │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│    Azure Infrastructure                 │
│  - Compute: VMs, Kubernetes             │
│  - Storage: Blob Storage, Data Lake     │
│  - Networking: VNets, Security          │
└─────────────────────────────────────────┘
```

### 1.5 Databricks Cần Những Gì?

**Yêu cầu để sử dụng Databricks trên Azure:**

1. **Tài khoản Azure** - Với subscription có thể thanh toán
2. **Azure Resource Group** - Nơi để tạo workspace
3. **Quyền Admin** - Tối thiểu là Contributor role
4. **Workspace Databricks** - Điểm truy cập chính (tương tự như tài khoản AWS)
5. **Cluster** - Nhóm máy tính chạy Spark (có thể tự động scale)
6. **Storage** - Blob Storage hoặc Data Lake cho lưu trữ dữ liệu

---

## PHẦN 2: TERRAFORM CÓ THỂ LÀM GÌ VỚI DATABRICKS?

### 2.1 Databricks Terraform Provider

Databricks cung cấp một **Terraform Provider** chính thức cho phép bạn quản lý Databricks resources dưới dạng IaC (Infrastructure as Code).

### 2.2 Các Tài Nguyên (Resources) Bạn Có Thể Quản Lý

| Resource               | Mô Tả                                      | Ví Dụ                                                 |
| ---------------------- | ------------------------------------------ | ----------------------------------------------------- |
| **Clusters**           | Tạo/xóa/quản lý cluster Spark              | `azurerm_databricks_workspace` + `databricks_cluster` |
| **Jobs**               | Định nghĩa jobs để chạy notebooks hoặc JAR | `databricks_job`                                      |
| **Notebooks**          | Upload/quản lý notebook code               | `databricks_notebook`                                 |
| **Service Principals** | Tạo service account cho automation         | `databricks_service_principal`                        |
| **Access Control**     | Cấp quyền truy cập clusters, folders       | `databricks_permissions`                              |
| **Git Repos**          | Kết nối Git repositories                   | `databricks_repo`                                     |
| **SQL Warehouses**     | Quản lý SQL endpoints                      | `databricks_sql_endpoint`                             |
| **Instance Pools**     | Quản lý nhóm instances                     | `databricks_instance_pool`                            |
| **Token/Secrets**      | Quản lý authentication tokens              | `databricks_obo_token`, `databricks_secret_scope`     |
| **Catalogs & Schemas** | Quản lý metadata (Unity Catalog)           | `databricks_catalog`, `databricks_schema`             |

### 2.3 Terraform Có Thể Làm Được Gì?

**Với Terraform + Databricks Provider, bạn có thể:**
✅ **Tự động hóa triển khai** - Tạo toàn bộ Databricks workspace + resources lần đầu
✅ **Phiên bản hóa cấu hình** - Lưu trữ tất cả cấu hình trong Git
✅ **Tái sử dụng** - Tạo nhiều environments (dev, test, prod) từ code tương tự
✅ **Quản lý lifecycle** - Tạo, cập nhật, xóa resources một cách nhất quán
✅ **Infrastructure as Code** - Mô tả cấu hình dưới dạng code thay vì manual clicks
✅ **Disaster Recovery** - Nếu workspace bị xóa, dựng lại trong phút
✅ **Kiểm soát quyền truy cập** - Tự động cấp quyền cho teams
✅ **Quản lý CI/CD** - Tích hợp với GitHub Actions, Azure DevOps

❌ **KHÔNG thể làm:**
- Chạy Spark jobs (Databricks chạy, Terraform chỉ quản lý)
- Quản lý dữ liệu bên trong tables (dùng SQL/Spark notebooks)
- Monitoring & logging (dùng Azure Monitor hoặc Databricks UI)

---

## PHẦN 3: QỒNG TRÌNH SETUP TERRAFORM + DATABRICKS

### 3.1 Bước 1: Chuẩn Bị Điều Kiện

```bash
# Cài đặt Terraform (nếu chưa có)
terraform version

# Cài đặt Azure CLI
az --version

# Đăng nhập Azure
az login

# Chọn subscription
az account set --subscription "your-subscription-id"
```

### 3.2 Bước 2: Tạo Cấu Hình Terraform

**Tạo thư mục mới:**

```bash
mkdir databricks-terraform
cd databricks-terraform
```

**Tạo file `versions.tf`:**

    ```hcl
    terraform {
    required_version = ">= 1.0"

    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 3.0"
        }
        databricks = {
        source  = "databricks/databricks"
        version = "~> 1.0"
        }
    }
    }

    provider "azurerm" {
    features {}
    subscription_id = "your-subscription-id"  # Thay bằng subscription ID của bạn
    }

    # Databricks provider sẽ được configure sau
    ```

**Tạo file `main.tf`:**

    ```hcl
    # Tạo Resource Group
    resource "azurerm_resource_group" "this" {
    name     = "rg-databricks-demo"
    location = "Southeast Asia"
    }

    # Tạo Databricks Workspace trên Azure
    resource "azurerm_databricks_workspace" "this" {
    name                = "databricks-workspace"
    resource_group_name = azurerm_resource_group.this.name
    location            = azurerm_resource_group.this.location
    sku                 = "standard"  # Có thể là: standard, premium, trial

    depends_on = [azurerm_resource_group.this]
    }

    provider "databricks" {
    host = azurerm_databricks_workspace.this.workspace_url
    
    # Terraform will automatically use your Azure CLI token
    # (you have to run `az login` first)
    }
    ```

**Tạo file `variables.tf`:**

    ```hcl
    variable "resource_group_name" {
    type    = string
    default = "rg-databricks-demo"
    }

    variable "workspace_name" {
    type    = string
    default = "databricks-workspace"
    }

    variable "location" {
    type    = string
    default = "Southeast Asia"
    }
    ```

**Tạo file `outputs.tf`:**

    ```hcl
    output "workspace_id" {
    value = azurerm_databricks_workspace.this.workspace_id
    }

    output "workspace_url" {
    value = azurerm_databricks_workspace.this.workspace_url
    }
    ```

**Lỗi "Error: Cycle: databricks_service_principal.this, databricks_obo_token.this, provider["registry.terraform.io/databricks/databricks"].main" và cách khắc phục khi chạy command "terraform validate"**

`databricks_obo_token` không hỗ trợ trên Azure Databricks, nó chỉ hoạt động trên AWS.

**Solution 1**: Dùng Azure CLI Authentication (KHUYẾN CÁO - Không Cần OBO Token)

**Trong file `main.tf`:**

    ```hcl
    # Create Resource Group
    resource "azurerm_resource_group" "this" {
    name     = "rg-databricks-demo"
    location = "Southeast Asia"
    }

    # Create Databricks Workspace trên Azure
    resource "azurerm_databricks_workspace" "this" {
    name                = "databricks-workspace"
    resource_group_name = azurerm_resource_group.this.name
    location            = azurerm_resource_group.this.location
    sku                 = "standard"  # Supported value: standard, premium, trial

    depends_on = [azurerm_resource_group.this]
    }

    # Configure Databricks provider (obtain info from workspace)
    # ✅ Solution: Using Azure CLI authentication (simple & no need to use OBO token)
    provider "databricks" {
    host = azurerm_databricks_workspace.this.workspace_url

    # Terraform will automatically use your Azure CLI token
    # (you have to run `az login` first)
    }
    ```

Then run the following commands:

    ```
    # 1. Ensure you have alreadu logged into Azure
    az login

    # 2. Select subscription
    az account set --subscription "8d42870d-3e7a-48d8-8dcf-8b20ed4c5ad6"

    # 3. Init Terraform
    terraform init

    # 4. Validate
    terraform validate

    # 5. Plan
    terraform plan

    # 6. Apply
    terraform apply
    ```

**Solution 2**: Sử Dụng Personal Access Token (Nếu Muốn Automation Hoàn Toàn)

1. Tạo Personal Access Token trong Databricks UI (https://adb-2411201584278267.7.azuredatabricks.net)
    1. Đăng nhập vào Databricks workspace
    2. Nhấp vào Settings (góc phải trên)
    3. Chọn Developer
    4. Chọn Personal access tokens
    5. Nhấp Generate new token
    6. Copy token

2. Update `main.tf`

```hcl
...
# ✅ Using Personal Access Token
provider "databricks" {
  host  = azurerm_databricks_workspace.this.workspace_url
  token = var.databricks_token  # Will be provided from the environment variable
}
```

3. Update `variables.tf`

```hcl
variable "databricks_token" {
  type        = string
  sensitive   = true
  description = "Databricks personal access token"
}
```

4. Create `terraform.tfvars`

```hcl
databricks_token = "dapi..."
```

5. Run terraform commands:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### 3.3 Bước 3: Chạy Terraform

```bash
# Init Terraform
terraform init

# Validate syntax of Terraform source
terraform validate

# Review all changes before applying them.
terraform plan

# Triển khai
terraform apply
```

---

## PHẦN 4: VÍ DỤ THỰC TẾ - TẠO CLUSTER & JOB

### 4.1 Tạo Cluster

**Thêm vào `main.tf`:**

```hcl
# Tạo Cluster Databricks
resource "databricks_cluster" "demo" {
  provider         = databricks.main
  cluster_name     = "demo-cluster"
  spark_version    = "13.3.x-scala2.12"  # Phiên bản Spark
  node_type_id     = "Standard_DS4_v2"   # Loại VM
  num_workers      = 2                    # Số worker nodes
  autotermination_minutes = 10            # Tự động tắt sau 10 phút

  aws_attributes {
    availability         = "ON_DEMAND"
    zone_id             = "us-west-2a"
  }
}

output "cluster_id" {
  value = databricks_cluster.demo.id
}
```

### 4.2 Tạo Job

**Thêm vào `main.tf`:**

```hcl
# Tạo notebook
resource "databricks_notebook" "demo" {
  provider = databricks.main
  path     = "/demo_notebook"
  language = "PYTHON"
  source   = file("${path.module}/notebooks/demo.py")
}

# Tạo Job chạy notebook hàng ngày
resource "databricks_job" "demo" {
  provider = databricks.main
  name     = "demo-job"

  task {
    task_key = "demo_task"

    notebook_task {
      notebook_path = databricks_notebook.demo.path
    }

    existing_cluster_id = databricks_cluster.demo.id
  }

  schedule {
    quartz_cron_expression = "0 9 * * ? *"  # Chạy lúc 9 giờ sáng mỗi ngày
    timezone_id            = "Asia/Ho_Chi_Minh"
  }
}

output "job_id" {
  value = databricks_job.demo.id
}
```

---

## PHẦN 5: AUTHENTICATE TERRAFORM VỚI DATABRICKS

### 5.1 Phương Pháp 1: Personal Access Token (Cách Nhanh Nhất)

**Bước 1: Tạo PAT trong Databricks UI**

- Đăng nhập Databricks workspace
- Vào **Settings** → **User Settings** → **Access tokens**
- Nhấp **Generate new token**
- Copy token

**Bước 2: Thiết lập biến môi trường**

```bash
# Windows (PowerShell)
$env:DATABRICKS_TOKEN = "your-token-here"

# Linux/Mac
export DATABRICKS_TOKEN="your-token-here"
```

**Bước 3: Cập nhật `main.tf`**

```hcl
provider "databricks" {
  host  = "https://your-databricks-instance.cloud.databricks.com"
  token = var.databricks_token
}

variable "databricks_token" {
  type      = string
  sensitive = true
  # Sẽ được cung cấp từ biến môi trường
}
```

### 5.2 Phương Pháp 2: Service Principal (Bảo Mật Hơn)

```hcl
provider "databricks" {
  host       = azurerm_databricks_workspace.this.workspace_url
  client_id  = databricks_service_principal.this.application_id
  client_secret = var.databricks_client_secret
  tenant_id  = data.azurerm_client_config.current.tenant_id
  auth_type  = "azure-cli"
}

data "azurerm_client_config" "current" {}

variable "databricks_client_secret" {
  type      = string
  sensitive = true
}
```

---

## PHẦN 6: BEST PRACTICES

### 6.1 Tổ Chức Thư Mục

    ```
    databricks-terraform/
    ├── versions.tf          # Provider versions
    ├── main.tf              # Resource chính
    ├── variables.tf         # Variable definitions
    ├── outputs.tf           # Output values
    ├── terraform.tfvars     # Values (không commit lên Git)
    ├── .gitignore           # Bỏ qua state files
    ├── notebooks/
    │   ├── demo.py
    │   └── etl_job.sql
    └── modules/             # Reusable modules
        ├── cluster/
        ├── job/
        └── workspace/
    ```

### 6.2 Tránh Các Lỗi Thường Gặp

❌ **Lỗi 1**: Hardcode credentials trong code
✅ **Giải pháp**: Sử dụng biến môi trường hoặc Azure Key Vault

❌ **Lỗi 2**: Commit `terraform.tfstate` lên Git
✅ **Giải pháp**: Thêm vào `.gitignore`, sử dụng remote state

❌ **Lỗi 3**: Quên chỉ định `provider` để phân biệt multiple providers
✅ **Giải pháp**: Sử dụng `alias` và `provider` argument

❌ **Lỗi 4**: Xóa cluster mà chưa backup job
✅ **Giải pháp**: Luôn sử dụng `terraform plan` trước `apply`

### 6.3 Sử Dụng Remote State

**Lưu Terraform state vào Azure Blob Storage:**

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate123"
    container_name       = "tfstate"
    key                  = "databricks.tfstate"
  }
}
```

---

## PHẦN 7: CÂU HỎI THƯỜNG GẶP

**Q: Databricks có thể xử lý được bao nhiêu dữ liệu?**
A: Apache Spark có thể xử lý từ GB đến TB hoặc PB dữ liệu tùy theo cluster size. Autoscaling giúp tối ưu chi phí.

**Q: Sự khác biệt giữa Databricks trên AWS vs Azure?**
A: Chức năng gần như nhau, nhưng Databricks on Azure tích hợp sâu với Azure services (Azure Storage, Azure Data Lake, Azure Synapse).

**Q: Terraform có thể chạy Spark jobs không?**
A: Không, Terraform chỉ quản lý infrastructure. Bạn chạy jobs thông qua Databricks API hoặc UI.

**Q: Chi phí Databricks là bao nhiêu?**
A: Tính theo DBU (Databricks Unit). Tùy SKU (standard, premium) và usage. Có free tier để học tập.

**Q: Tôi có thể import workspace hiện tại vào Terraform không?**
A: Có, sử dụng `terraform import` command để import existing resources.

---

## PHẦN 8: TÀI NGUYÊN HỮU ÍCH

- [Databricks Terraform Provider Docs](https://registry.terraform.io/providers/databricks/databricks/latest/docs)
- [Azure Databricks Documentation](https://learn.microsoft.com/en-us/azure/databricks/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Databricks Learning Path](https://learn.databricks.com/)

---

## TÓMLẠT

| Khái Niệm                  | Định Nghĩa                                                                 |
| -------------------------- | -------------------------------------------------------------------------- |
| **Databricks**             | Nền tảng phân tích dữ liệu hợp nhất trên cloud, xây dựng trên Apache Spark |
| **Workspace**              | Không gian làm việc của Databricks (tương tự thư mục)                      |
| **Cluster**                | Nhóm máy tính chạy Spark (cần để thực thi code)                            |
| **Job**                    | Tác vụ lập lịch chạy notebooks hoặc scripts                                |
| **Terraform Provider**     | Công cụ cho phép Terraform quản lý Databricks resources                    |
| **Infrastructure as Code** | Mô tả cơ sở hạ tầng dưới dạng code                                         |

Chúc bạn thành công trong hành trình làm quen với Databricks và Terraform! 
