#!/usr/bin/env python3

import sqlite3, os, csv
import sys


dir_path = os.path.dirname(os.path.realpath(__file__))
print(f"\nworking in folder {dir_path}....\n")
con = None

unsent_payment_pattern = "(amount > 0 AND transaction_processdata IS NULL AND type_id = 2 AND processor_accepted = 0)"

def load_fp_invoicenos():
    with open(f"{dir_path}/foobar.csv") as file:
        reader = csv.reader(file)
        fp_invoice_numbers = [row[7] for row in reader]

    return fp_invoice_numbers[1::]

def load_db_invoicenos(cur):
    db_invoicenos = [x[0] for x in cur.execute(f"SELECT transaction_invoiceno FROM payment WHERE {unsent_payment_pattern}").fetchall()]
    return db_invoicenos

def compare_invoicenos(db_invoicenos, fp_invoicenos):
    unsent_invoicenos = [invoiceno for invoiceno in db_invoicenos if invoiceno not in fp_invoicenos]
    return unsent_invoicenos

def get_unsent_ordernos(cur, missing_invoicenos):
    ids = [x[0] for x in cur.execute(f"SELECT order_id FROM payment WHERE transaction_invoiceno IN ({','.join(missing_invoicenos)})").fetchall()]
    unsent_ordernos = [x[0] for x in cur.execute(f"SELECT res_id FROM purchase_order WHERE id IN ({','.join(map(str, ids))})").fetchall()]
    return unsent_ordernos

def main():
    try:
        #initiate DB and cursor
        con = sqlite3.connect(dir_path+'/db.sqlite')
        cur = con.cursor()
        db_invoicenos = load_db_invoicenos(cur)
        #print(f"db invoicenos:{db_invoicenos}")
        if len(db_invoicenos) == 0:
            print("No unsent payments found in DB")
            return
        fp_invoicenos = load_fp_invoicenos()
        #print(f"fp invoicenos:{fp_invoicenos}")
        missing_invoicenos = compare_invoicenos(db_invoicenos, fp_invoicenos)
        #print(f"missing invoicenos:{missing_invoicenos}")
        unsent_ordernos = get_unsent_ordernos(cur, missing_invoicenos)

        if len(unsent_ordernos) == 0:
            print("No payments missing from FP")
            return

        print(f"{len(unsent_ordernos)} orders have not been found in FP report. Order numbers:")
        print(unsent_ordernos)

        while True:
            user_continue = input("\nWould you like to continue? (y/n)")
            if user_continue == 'n':
                print("no selected - exiting...")
                #con.close()
                sys.exit()
            elif user_continue == 'y':
                print ("yes selected - preparing database...")
                break
            elif user_continue != 'n' and user_continue != 'y':
                print ("incorrect input, enter y to continue or n to close")

        #check for unsent orders and mark sent
        cur.execute("UPDATE purchase_order SET status = 2 WHERE status = 0")

        #run executed fixer
        cur.execute(f"UPDATE payment SET executed = 0 WHERE transaction_invoiceno IN ({','.join(missing_invoicenos)})")

        #skip customer sync to make DB load faster
        cur.execute("UPDATE settings SET setting_value = 'no' WHERE setting_name = 1222")
        cur.execute("UPDATE settings SET setting_value = 1917706408 WHERE setting_name = 1139")

        #commit changes
        con.commit()
        con.close()

    except sqlite3.Error as e:
        print(f"Error {e.args[0]}")
        return
        
    finally:
        os.rename(dir_path+"/db.sqlite",dir_path+"/pos2v.sqlite")
        print("Sucess")


if __name__ == "__main__":
    main()

#credits(c) Dominykas Jasiulionis, Pasha also helped and Vikce finished it up