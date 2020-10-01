// My solution was strongly inspired by that of 
// Jonny Kong CSC343 FALL 2017


import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
            connection = DriverManager.getConnection(url, username, password);
        } catch(SQLException se) {
            return false;
        }
        // System.out.println("Connected to database");
        return true;
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        if(connection != null) {
            try {
                connection.close();
            } catch (SQLException se) {
                return false;
            }
        }
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        List<Integer> elections = new ArrayList<Integer>();
        List<Integer> cabinets = new ArrayList<Integer>();

        try {
            String queryString = "SELECT election.id AS election_id, cabinet.id AS cabinet_id " +
                "FROM election, country, cabinet " +
                "WHERE election.country_id = country.id AND " +
                "election.id = cabinet.election_id AND " +
                "country.name = ?" + 
                "ORDER BY election.e_date DESC;";
            
            PreparedStatement preparedStatement = connection.prepareStatement(queryString);
            preparedStatement.setString(1, countryName);
            
            ResultSet resultSet = preparedStatement.executeQuery();
            while(resultSet.next()) {
                elections.add(resultSet.getInt("election_id"));
                cabinets.add(resultSet.getInt("cabinet_id"));
            }
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
        }

        return new ElectionCabinetResult(elections, cabinets);
        // return null;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        List<Integer> nameList = new ArrayList<Integer>();

        try {
            // Get similarity of given politician
            String description = new String("");    // Initialize to empty string to suppress warnings
            String query1 = "SELECT description FROM politician_president " +
                "WHERE politician_president.id = ?";
            PreparedStatement preparedStatement1 = connection.prepareStatement(query1);
            preparedStatement1.setInt(1, politicianName);
            ResultSet resultSet1 = preparedStatement1.executeQuery();
            while(resultSet1.next()) {
                description = resultSet1.getString("description");
            }

            // Get all politicians and descriptions
            String query2 = "SELECT id, description " +
                "FROM politician_president;";
            PreparedStatement preparedStatement2 = connection.prepareStatement(query2);
            ResultSet resultSet2 = preparedStatement2.executeQuery();
            while(resultSet2.next()) {
                double similarity = similarity(resultSet2.getString("description"), description);
                if(similarity >= threshold) {
                    int id = resultSet2.getInt("id");
                    if(id != politicianName) nameList.add(id);  
                }
            }
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
        }

        return nameList;
    }

    // public static void main(String[] args) throws ClassNotFoundException {
    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.

    }

}

