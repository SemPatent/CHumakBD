import java.io.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Main {

    private static java.sql.Connection connection;
    private static java.sql.Statement statement;

    //метод подключения к БД
    public static void connectBD (String path, String nameBD, String user, String passvord) {
        try {
            Class.forName("org.postgresql.Driver");
            try{
                connection = DriverManager.getConnection(path + nameBD, user, passvord);
                try{
                    statement = connection.createStatement();
                } catch (SQLException exception) {
                    System.out.println(exception);
                }
            } catch (SQLException exception) {
                System.out.println("Ошибка в подкючении к БД " + exception);
            }
        } catch (ClassNotFoundException e) {
            System.out.println("Ошибка в подключении Драйверов " + e);
        }
    }

    public static void selectFromValVectorAsVov(List<Double> val_vector, List<Integer> id, double delta) throws SQLException
    {
        String val_vector_str = val_vector.toString();//переводим массив в строку
        val_vector_str = val_vector_str.replace('[', '{');//заменяем символы для коректного запроса
        val_vector_str = val_vector_str.replace(']', '}');

        String idStr = id.toString();
        idStr = idStr.replace('[', '{');
        idStr = idStr.replace(']', '}');

        String select = "SELECT DISTINCT result FROM values_​​of_the_vectors AS vov, compare_vector(vov.id, vov.id_type_table, '"+val_vector_str+"', '"+idStr+"', "+delta+") as result WHERE result IS NOT NULL limit 100";
        PreparedStatement ps = connection.prepareStatement(select);
       
        ps.executeQuery();
        ResultSet rs = ps.getResultSet();
        while (rs.next()) {
            String lastName = rs.getString("result");
        }


    }

    public static void main(String[] args) throws IOException, SQLException {
        //1 - путь до базы, 2 - имя БД, 3 - пароль
        connectBD("jdbc:postgresql://127.0.0.1:5432/", "qwe",  "postgres","1");//подключение к бд

        List<Integer> indexs = new ArrayList<Integer>();
        indexs.add(1);
        indexs.add(2);

        List<Double> rels = new ArrayList<Double>();

        rels.add(100.1);
        rels.add(200.0);

        selectFromValVectorAsVov(rels , indexs, 10.01);
    }
}
