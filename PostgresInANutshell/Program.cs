using Npgsql;
using System;
using System.Configuration;
using System.Threading.Tasks;

namespace PostgresInaNutshell
{
    class Program
    {
        static async Task Main(string[] args)
        {
            SqlHandler sqlHandler = new SqlHandler(ConfigurationManager.ConnectionStrings["dvdrental"].ConnectionString);
            // var id = await sqlHandler.InsertEntryAsync();
            // var id = await sqlHandler.UpdateEntryAsync(207);
            // sqlHandler.SelectEntry(id);
            var firstName = await sqlHandler.DeleteEntryAsync(206);
            Console.WriteLine(firstName);
            Console.Read();
        }
    }
}
