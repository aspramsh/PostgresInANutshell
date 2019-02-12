using Npgsql;
using System;
using System.Threading.Tasks;

namespace PostgresInaNutshell
{
    public class SqlHandler
    {
        private readonly string _connectionString;

        public SqlHandler(string connectionString)
        {
            _connectionString = connectionString;
        }

        public void SelectEntry(int id)
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                string query = $"SELECT * FROM actor WHERE actor_id = {id}";
                var cmd = new NpgsqlCommand(query, conn);
                var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    Console.WriteLine($"{reader["first_name"]} {reader["last_name"]}");
                }
                cmd.Dispose();
            }

            Console.Read();
        }

        public async Task<int> InsertEntryAsync()
        {
            int actorId = default;
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new NpgsqlCommand(@"INSERT INTO public.actor(first_name, last_name) 
                                                                   VALUES('Lily', 'Allen') 
                                                                   RETURNING actor_id; ", conn);

                actorId = (int)await cmd.ExecuteScalarAsync();
                
                cmd.Dispose();
            }

            return actorId;
        }

        public async Task<int> UpdateEntryAsync(int id)
        {
            int actorId = default;
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new NpgsqlCommand($"UPDATE actor SET first_name = 'Woody'" + 
                                                 $"WHERE actor_id = {id}" + 
                                                 "RETURNING actor_id;", conn);
                actorId = (int)await cmd.ExecuteScalarAsync();

                cmd.Dispose();
            }

            return actorId;
        }

        public async Task<string> DeleteEntryAsync(int id)
        {
            string firstName = default;
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                conn.Open();
                var cmd = new NpgsqlCommand($"DELETE FROM actor WHERE actor_id = {id} RETURNING last_name; ", conn);

                firstName = (string)await cmd.ExecuteScalarAsync();

                cmd.Dispose();
            }

            return firstName;
        }
    }
}
