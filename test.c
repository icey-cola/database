#include <gtk/gtk.h>
#include <libpq-fe.h>  // PostgreSQL 客户端库
#include <stdio.h>
#include <stdlib.h>

// 声明回调函数
static void on_execute_button_clicked(GtkButton *button, gpointer user_data);
static void on_window_destroy(GtkWidget *widget, gpointer data);
static char* read_sql_from_file(const char *filename);
static void show_query_result_window(const char *query_result);

int main(int argc, char *argv[]) {
    GtkWidget *window, *vbox, *button, *scrolled_window, *text_view;
    GtkTextBuffer *buffer;

    // 初始化 GTK
    gtk_init(&argc, &argv);

    // 创建一个窗口
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "SQL Executor");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 300);

    // 设置关闭窗口的回调
    g_signal_connect(window, "destroy", G_CALLBACK(on_window_destroy), NULL);

    // 创建一个垂直容器
    vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    gtk_container_add(GTK_CONTAINER(window), vbox);

    // 创建一个按钮
    button = gtk_button_new_with_label("Execute SQL from File");
    gtk_box_pack_start(GTK_BOX(vbox), button, FALSE, FALSE, 0);

    // 创建一个文本视图显示执行结果
    scrolled_window = gtk_scrolled_window_new(NULL, NULL);
    gtk_box_pack_start(GTK_BOX(vbox), scrolled_window, TRUE, TRUE, 0);

    text_view = gtk_text_view_new();
    gtk_container_add(GTK_CONTAINER(scrolled_window), text_view);
    buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(text_view));

    // 连接按钮点击事件
    g_signal_connect(button, "clicked", G_CALLBACK(on_execute_button_clicked), buffer);

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
    const char *sql_query = read_sql_from_file("createuser.sql");
    if (sql_query == NULL) {
        gtk_text_buffer_set_text(buffer, "Failed to read SQL file.\n", -1);
        return;
    }

    // 创建一个 PostgreSQL 连接
    const char *conninfo = "dbname=mydb user=postgres password=wjr20031024 host=localhost";
    PGconn *conn = PQconnectdb(conninfo);

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
    gtk_window_set_default_size(GTK_WINDOW(result_window), 400, 300);

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

// 关闭窗口时退出 GTK 主循环
static void on_window_destroy(GtkWidget *widget, gpointer data) {
    gtk_main_quit();
}
