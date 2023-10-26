using sqlapp.Models;
using System.Data.SqlClient;

namespace sqlapp.Services
{

    // This service will interact with our Product data in the SQL database
    public class CourseService
    {
        private static string db_source = "dataeng123.database.windows.net";
        private static string db_user = "dataeng";
        private static string db_password = "Dubai@123@123";
        private static string db_database = "dataeng";

        private SqlConnection GetConnection()
        {
            
            var _builder = new SqlConnectionStringBuilder();
            _builder.DataSource = db_source;
            _builder.UserID = db_user;
            _builder.Password = db_password;
            _builder.InitialCatalog = db_database;
            return new SqlConnection(_builder.ConnectionString);
        }
        public List<Course> GetCourses()
        {
            List<Course> _course_lst = new List<Course>();
            string _statement = "SELECT CourseID,ExamImage,CourseName,rating from Course";
            SqlConnection _connection = GetConnection();
            
            _connection.Open();
            
            SqlCommand _sqlcommand = new SqlCommand(_statement, _connection);
            
            using (SqlDataReader _reader = _sqlcommand.ExecuteReader())
            {
                while (_reader.Read())
                {
                    Course _course = new Course()
                    {
                        CourseID = _reader.GetInt32(0),
                        ExamImage = _reader.GetString(1),
                        CourseName = _reader.GetString(2),
                        Rating = _reader.GetDecimal(3)
                    };

                    _course_lst.Add(_course);
                }
            }
            _connection.Close();
            return _course_lst;
        }

    }
}

