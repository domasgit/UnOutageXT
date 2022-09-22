#!/usr/bin/env python3

import sqlite3, os, csv
import sys


dir_path = os.path.dirname(os.path.realpath(__file__))
print(dir_path)
con = None

unsent_payment_pattern = "(amount > 0 AND transaction_processdata IS NULL AND type_id = 2 AND processor_accepted = 0)"

def load_fp_invoicenos():
    with open('foobar.csv') as file:
        reader = csv.reader(file)
        fp_invoice_numbers = [row[7] for row in reader]

    return fp_invoice_numbers[1::]

def check_unsent_declines(cur):
    count = cur.execute(f"SELECT COUNT(*) FROM payment WHERE {unsent_payment_pattern}").fetchone()[0]
    return count

def main():
    try:
        #initiate DB and cursor
        fp_invoicenos = load_fp_invoicenos()
        print(fp_invoicenos)
        con = sqlite3.connect(dir_path+'/db.sqlite')
        cur = con.cursor()

        count = check_unsent_declines(cur)

        if count == 0:
            print("No unsent payments found in DB")
            return

#        invoicenos = cur.execute(f"SELECT transaction_invoiceno FROM payment WHERE {unsent_payment_pattern}").fetchall()
        db_invoicenos = [x[0] for x in cur.execute(f"SELECT transaction_invoiceno FROM payment WHERE {unsent_payment_pattern}").fetchall()]
        print(db_invoicenos)

        unsent_invoicenos = [invoiceno for invoiceno in db_invoicenos if invoiceno not in fp_invoicenos]
        print(unsent_invoicenos)

        #check for unsent orders and mark sent
        cur.execute("UPDATE purchase_order SET status = 2 WHERE status = 0")

        #run executed fixer
#        cur.execute(f"UPDATE payment SET executed = 0 WHERE transaction_invoiceno IN ({','.join(unsent_invoicenos)})")
        con.commit()
        con.close()

    except sqlite3.Error as e:
        print(f"Error {e.args[0]}")
        return
        
#    finally:
#        os.rename(dir_path+"/db.sqlite",dir_path+"/pos2v.sqlite")


if __name__ == "__main__":
    main()

#credits(c) Dominykas Jasiulionis, Pasha also helped and Vikce finished it up