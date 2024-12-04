#include <gtk/gtk.h>
#include <libpq-fe.h>  // PostgreSQL 客户端库
#include <stdio.h>
#include <stdlib.h>
#define DB_NAME "mydb"
#define DB_USER "postgres"
#define DB_PASSWORD "wjr20031024"
#define DB_HOST "localhost"
#define CONNECTION_INFO "dbname=" DB_NAME " user=" DB_USER " password=" DB_PASSWORD " host=" DB_HOST
// 声明回调函数
static void on_execute_button_clicked(GtkButton *button, gpointer user_data);
static void on_window_destroy(GtkWidget *widget, gpointer data);
static char* read_sql_from_file(const char *filename);
static void show_query_result_window(const char *query_result);
static void on_createuser_button_clicked(GtkButton *button, gpointer user_data);
void replace_placeholder(char *query, const char *placeholder, const char *value, char *result, size_t result_size);
int main(int argc, char *argv[]) {
    GtkWidget *window, *vbox, *button,*button_createuser, *scrolled_window, *text_view;
    GtkTextBuffer *buffer;

    // 初始化 GTK
    gtk_init(&argc, &argv);

    // 创建一个窗口
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "SQL Executor");
    gtk_window_set_default_size(GTK_WINDOW(window), 800, 600);

    // 设置关闭窗口的回调
    g_signal_connect(window, "destroy", G_CALLBACK(on_window_destroy), NULL);

    // 创建一个垂直容器
    vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    gtk_container_add(GTK_CONTAINER(window), vbox);

    // 创建一个按钮
    button = gtk_button_new_with_label("init");
    gtk_box_pack_start(GTK_BOX(vbox), button, FALSE, FALSE, 0);
    button_createuser = gtk_button_new_with_label("createuser");
    gtk_box_pack_start(GTK_BOX(vbox), button_createuser, FALSE, FALSE, 0);
    // 创建一个文本视图显示执行结果
    scrolled_window = gtk_scrolled_window_new(NULL, NULL);
    gtk_box_pack_start(GTK_BOX(vbox), scrolled_window, TRUE, TRUE, 0);
    text_view = gtk_text_view_new();
    gtk_container_add(GTK_CONTAINER(scrolled_window), text_view);
    buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(text_view));
    // 创建一个文本视图显示执行结果
    GtkWidget  *scrolled_window2, *text_view2;
    GtkTextBuffer *buffer_createuser;
    scrolled_window2 = gtk_scrolled_window_new(NULL, NULL);
    gtk_box_pack_start(GTK_BOX(vbox), scrolled_window2, TRUE, TRUE, 0);
    text_view2 = gtk_text_view_new();
    gtk_container_add(GTK_CONTAINER(scrolled_window2), text_view2);
    buffer_createuser = gtk_text_view_get_buffer(GTK_TEXT_VIEW(text_view2));

    // 连接按钮点击事件
    g_signal_connect(button, "clicked", G_CALLBACK(on_execute_button_clicked), buffer);
    g_signal_connect(button_createuser, "clicked", G_CALLBACK(on_createuser_button_clicked), buffer_createuser);
    // 显示所有组件
    gtk_widget_show_all(window);

    // 运行 GTK 主循环
    gtk_main();

    return 0;
}

// 执行 SQL 查询的回调函数
static void on_execute_button_clicked(GtkButton *button, gpointer user_data) {
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(user_data);

    // 从文件中读取 SQL 语句
    const char *sql_query = read_sql_from_file("./sql/init.sql");
    if (sql_query == NULL) {
        gtk_text_buffer_set_text(buffer, "Failed to read SQL file.\n", -1);
        return;
    }

    // 创建一个 PostgreSQL 连接
    //const char *conninfo = "dbname=mydb user=postgres password=wjr20031024 host=localhost";
    PGconn *conn = PQconnectdb(CONNECTION_INFO);

    // 检查连接是否成功
    if (PQstatus(conn) != CONNECTION_OK) {
        gtk_text_buffer_set_text(buffer, "Connection to database failed.\n", -1);
        PQfinish(conn);
        return;
    }

    // 执行 SQL 查询
    PGresult *res = PQexec(conn, sql_query);

    // 检查查询是否成功
    if (PQresultStatus(res) != PGRES_COMMAND_OK && PQresultStatus(res) != PGRES_TUPLES_OK) {
        gtk_text_buffer_set_text(buffer, "SQL Query failed.\n", -1);
        gtk_text_buffer_insert_at_cursor(buffer, PQerrorMessage(conn), -1);
        PQclear(res);
        PQfinish(conn);
        return;
    }

   // 获取查询结果并显示
       // 构造查询结果文本
          int nrows = PQntuples(res);  // 获取结果行数
    int ncols = PQnfields(res);  // 获取列数
    char result_text[4096] = "";  // 用于存储查询结果的字符串

    for (int i = 0; i < nrows; i++) {
        for (int j = 0; j < ncols; j++) {
            const char *value = PQgetvalue(res, i, j);  // 获取每个单元格的值
            strcat(result_text, value);  // 拼接查询结果
            strcat(result_text, "\t");  // 列之间添加制表符
        }
        strcat(result_text, "\n");  // 每行结束后换行
    }

    // 显示查询结果
    show_query_result_window(result_text);

    // 清理
    PQclear(res);
    PQfinish(conn);
}

// 弹出一个新窗口显示查询结果
static void show_query_result_window(const char *query_result) {
    GtkWidget *result_window, *vbox, *scrolled_window, *text_view;
    GtkTextBuffer *buffer;

    // 创建一个新的窗口
    result_window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(result_window), "Query Result");
    gtk_window_set_default_size(GTK_WINDOW(result_window), 800, 600);

    // 创建一个垂直容器
    vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    gtk_container_add(GTK_CONTAINER(result_window), vbox);

    // 创建一个文本视图来显示查询结果
    scrolled_window = gtk_scrolled_window_new(NULL, NULL);
    gtk_box_pack_start(GTK_BOX(vbox), scrolled_window, TRUE, TRUE, 0);

    text_view = gtk_text_view_new();
    gtk_container_add(GTK_CONTAINER(scrolled_window), text_view);
    buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(text_view));

    // 设置文本缓冲区的内容
    gtk_text_buffer_set_text(buffer, query_result, -1);

    // 显示新窗口和所有组件
    gtk_widget_show_all(result_window);
}
// 从文件中读取 SQL 内容
static char* read_sql_from_file(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        return NULL;
    }

    // 获取文件大小
    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);

    // 为文件内容分配内存
    char *content = (char *)malloc(file_size + 1);
    if (content == NULL) {
        fclose(file);
        return NULL;
    }

    // 读取文件内容
    fread(content, 1, file_size, file);
    content[file_size] = '\0';  // 确保字符串末尾是空字符

    fclose(file);
    return content;
}

void replace_placeholder(char *query, const char *placeholder, const char *value, char *result, size_t result_size) {
    char *pos = strstr(query, placeholder);
    if (pos == NULL) {
        // 如果没有找到占位符，直接复制原始字符串
        strncpy(result, query, result_size - 1);
        result[result_size - 1] = '\0';
        return;
    }

    size_t before_placeholder_len = pos - query;
    size_t value_len = strlen(value);
    size_t after_placeholder_len = strlen(pos + strlen(placeholder));

    if (before_placeholder_len + value_len + after_placeholder_len >= result_size) {
        // 防止缓冲区溢出
        fprintf(stderr, "Error: Result buffer is too small for the replaced string.\n");
        exit(1);
    }

    // 将占位符前面的部分复制到结果缓冲区
    strncpy(result, query, before_placeholder_len);

    // 特殊处理 %is_admin% 占位符，移除引号
    if (strcmp(placeholder, "%is_admin%") == 0) {
        if (strcmp(value, "TRUE") == 0 || strcmp(value, "FALSE") == 0) {
            // 插入布尔值，不加引号
            strncpy(result + before_placeholder_len, value, value_len);
        } else {
            // 如果不是布尔值，则仍然插入完整的值
            strncpy(result + before_placeholder_len, value, value_len);
        }
    } else {
        // 普通占位符替换
        strncpy(result + before_placeholder_len, value, value_len);
    }

    // 将占位符后面的部分复制到结果缓冲区
    strncpy(result + before_placeholder_len + value_len, pos + strlen(placeholder), after_placeholder_len);
    result[before_placeholder_len + value_len + after_placeholder_len] = '\0';
}


// 回调函数：当点击 createuser 按钮时执行
static void on_createuser_button_clicked(GtkButton *button, gpointer user_data) {
    GtkWidget *dialog, *vbox, *entry_username, *entry_password, *label_username, *label_password;
    const char *username, *password;
     GtkWidget *check_admin, *label_admin;
     gboolean is_admin;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(user_data);  // 这里的 buffer 用于输出结果

    // 创建一个对话框用于输入用户名和密码
    dialog = gtk_dialog_new_with_buttons("Create User", NULL, GTK_DIALOG_MODAL,
                                        "Cancel", GTK_RESPONSE_CANCEL,
                                        "Create", GTK_RESPONSE_ACCEPT,
                                        NULL);

    // 获取对话框的容器，并创建文本框和标签
    vbox = gtk_dialog_get_content_area(GTK_DIALOG(dialog));

    label_username = gtk_label_new("Username:");
    gtk_box_pack_start(GTK_BOX(vbox), label_username, FALSE, FALSE, 5);

    entry_username = gtk_entry_new();
    gtk_box_pack_start(GTK_BOX(vbox), entry_username, FALSE, FALSE, 5);

    label_password = gtk_label_new("Password:");
    gtk_box_pack_start(GTK_BOX(vbox), label_password, FALSE, FALSE, 5);

    entry_password = gtk_entry_new();
    gtk_entry_set_visibility(GTK_ENTRY(entry_password), FALSE);  // 隐藏密码
    gtk_box_pack_start(GTK_BOX(vbox), entry_password, FALSE, FALSE, 5);

      // Admin Checkbox
    check_admin = gtk_check_button_new_with_label("Is Admin?");
    gtk_box_pack_start(GTK_BOX(vbox), check_admin, FALSE, FALSE, 5);
   ;
    gtk_widget_show_all(dialog);  // 显示对话框

    // 等待用户操作
    gint result = gtk_dialog_run(GTK_DIALOG(dialog));

    // 获取输入的用户名和密码
    if (result == GTK_RESPONSE_ACCEPT) {
        username = gtk_entry_get_text(GTK_ENTRY(entry_username));
        password = gtk_entry_get_text(GTK_ENTRY(entry_password));
        is_admin = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(check_admin));
        printf("is_admin: %d\n", is_admin);
        // 读取 SQL 文件
        FILE *sql_file = fopen("./sql/createuser.sql", "r");
        if (!sql_file) {
            gtk_text_buffer_set_text(buffer, "Failed to open SQL file.\n", -1);
            gtk_widget_destroy(dialog);
            return;
        }

        // 读取文件内容到 buffer 中
        fseek(sql_file, 0, SEEK_END);
        long file_size = ftell(sql_file);
        fseek(sql_file, 0, SEEK_SET);
        char *sql_query = malloc(file_size + 1);
        fread(sql_query, 1, file_size, sql_file);
        sql_query[file_size] = '\0';  // 确保字符串结尾
        PGconn *conn = PQconnectdb(CONNECTION_INFO);
        if (PQstatus(conn) != CONNECTION_OK) {
            gtk_text_buffer_set_text(buffer, "Connection to database failed.\n", -1);
            PQfinish(conn);
            gtk_widget_destroy(dialog);
            return;
        }
        // 转义用户名和密码 防止密码中有引号
        char escaped_username[100], escaped_password[100];
        int username_len = strlen(username);
        int password_len = strlen(password);

        PQescapeStringConn(conn, escaped_username, username, username_len, NULL);
        PQescapeStringConn(conn, escaped_password, password, password_len, NULL);

        //printf("username: %s\n", escaped_username);
        //printf("password: %s\n", escaped_password);
        //printf("username_len: %d\n", username_len);
        // 替换占位符 %username% 和 %password% 为用户输入的值
        char modified_sql_query[1024];
        strncpy(modified_sql_query, sql_query, sizeof(modified_sql_query) - 1);
        //printf("%s\n", modified_sql_query);
        const char *admin_status = is_admin ? "TRUE" : "FALSE";
        // 替换 %username% 和 %password% 占位符
        replace_placeholder(sql_query, "%username%", escaped_username, modified_sql_query, sizeof(modified_sql_query));
        replace_placeholder(modified_sql_query, "%password%", escaped_password, modified_sql_query, sizeof(modified_sql_query));
        replace_placeholder(modified_sql_query, "%is_admin%", admin_status, modified_sql_query, sizeof(modified_sql_query));
        // 打印最终的 SQL 查询
        printf("Modified SQL query: %s\n", modified_sql_query);  

        // 执行 SQL 查询
        PGresult *res = PQexec(conn, modified_sql_query);

        // 检查执行是否成功
        if (PQresultStatus(res) != PGRES_COMMAND_OK) {
            gtk_text_buffer_set_text(buffer, "SQL Query failed.\n", -1);
            gtk_text_buffer_insert_at_cursor(buffer, PQerrorMessage(conn), -1);
        } else {
            gtk_text_buffer_set_text(buffer, "User created successfully.\n", -1);
        }

        // 清理
        PQclear(res);
        PQfinish(conn);

        free(sql_query);
    }

    gtk_widget_destroy(dialog);  // 销毁对话框
}

// 关闭窗口时退出 GTK 主循环
static void on_window_destroy(GtkWidget *widget, gpointer data) {
    gtk_main_quit();
}
