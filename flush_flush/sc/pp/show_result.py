import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

def plot_csv_data(file_path, output_path='output_plot.pdf'):
    try:
        # Load the CSV
        df = pd.read_csv(file_path)

        # Ensure numeric values
        df['timestamp_us'] = pd.to_numeric(df['timestamp_us'], errors='coerce')
        df['delta'] = pd.to_numeric(df['delta'], errors='coerce')
        df.dropna(subset=['timestamp_us', 'delta'], inplace=True)

        # Get unique labels
        unique_labels = df['label'].unique()

        # Use a clean, professional style
        plt.style.use("seaborn-v0_8-whitegrid")

        # Create the figure
        fig, ax = plt.subplots(figsize=(10, 5), dpi=120)

        # Plot lines for each label
        for label in unique_labels:
            subset = df[df['label'] == label]
            ax.plot(
                subset['timestamp_us'],
                subset['delta'],
                linestyle='-',
                linewidth=1.5,
                label=label,
                alpha=0.9
            )

        # Set axis labels
        ax.set_xlabel('Time (μs)', fontsize=14)
        ax.set_ylabel(r'$\Delta t$', fontsize=14, labelpad=15, rotation='horizontal')

        # Customize ticks
        ax.tick_params(axis='both', labelsize=12)
        ax.xaxis.set_major_locator(ticker.MaxNLocator(8))
        ax.yaxis.set_major_locator(ticker.MaxNLocator(6))

        # Style the grid
        ax.grid(True, linestyle='--', linewidth=0.5, alpha=0.3)

        # Add a legend
        ax.legend(fontsize=10, loc='best')

        # Improve layout
        plt.tight_layout()

        # Save to PDF
        plt.savefig(output_path, format='pdf')
        print(f"Plot saved as: {output_path}")

        plt.close()  # Close the figure after saving

    except FileNotFoundError:
        print(f"Error: The file '{file_path}' was not found.")
    except ValueError as ve:
        print(f"Data Error: {ve}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# Main runner
if __name__ == "__main__":
    plot_csv_data('timing_log.csv', 'timing_plot.pdf')
