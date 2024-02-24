import React from "react";

import styles from "./quotes.module.css";

type Quote = {
  quote_id: number;
  name: string;
  text: string;
};

export function Quotes() {
  const [isClient, setIsClient] = React.useState(true);
  const [page, setPage] = React.useState(1);
  const [perPage, setPerPage] = React.useState(10);

  const [quoteData, setQuoteData] = React.useState<Quote[]>([]);

  React.useEffect(() => {
    setIsClient(true);
    async function getQuotes() {
      const response = await fetch(
        "/quotes?" +
          new URLSearchParams({
            page: page.toString(),
            per_page: perPage.toString(),
          })
      );
      const quotes = await response.json();
      setQuoteData(quotes);
    }

    getQuotes();
  }, [page, perPage]);

  // TODO: hydrate properly or add skeleton
  return (
    <div className={styles.tableContainer}>
      <div className={styles.tableControls}>
        <input
          type="number"
          value={page}
          onChange={(event) => {
            event.preventDefault();
            const page = parseInt(event.target.value);
            if (page === 0) {
              return;
            }
            setPage(page);
          }}
        ></input>
        <button
          onClick={() => {
            setPage(page - 1);
          }}
        >
          Prev
        </button>
        <button
          onClick={() => {
            setPage(page + 1);
          }}
        >
          Next
        </button>
      </div>
      <div suppressHydrationWarning>
        {quoteData.length === 0 ? (
          "Loading..."
        ) : (
          <table className={styles.quotes}>
            <thead>
              <tr>
                <th className={styles.author}>Author</th>
                <th>Quote</th>
              </tr>
            </thead>
            <tbody>
              {quoteData.map((data) => {
                return (
                  <tr key={data.quote_id}>
                    <td className={styles.author}>{data.name}</td>
                    <td>{data.text}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
