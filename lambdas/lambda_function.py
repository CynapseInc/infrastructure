import boto3
import pandas as pd
import os
from io import StringIO
import urllib.parse

s3 = boto3.client('s3')

def lambda_handler(event, context):
    try:
        BUCKET_RAW = os.environ['BUCKET_RAW']
        BUCKET_TRUSTED = os.environ['BUCKET_TRUSTED']
        
        # Pega o nome do arquivo que ativou a Lambda
        key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

        # 1. Leitura
        obj = s3.get_object(Bucket=BUCKET_RAW, Key=key)
        df = pd.read_csv(obj['Body'])

        # 2. Tratamento
        df = df.dropna()
        df['imdb_100'] = pd.to_numeric(
            df['IMDb'].astype(str).str.replace('/10', '', regex=False),
            errors='coerce'
        ) * 10
        df['rottenTomatoes_100'] = pd.to_numeric(
            df['Rotten Tomatoes'].astype(str).str.replace('/100', '', regex=False),
            errors='coerce'
        )
        df = df.dropna()
        df = df[df['Year'] >= 2000]
        df = df[df['imdb_100'] >= 70]
        df = df[df['rottenTomatoes_100'] >= 70]

        plataformas = ['Netflix', 'Hulu', 'Prime Video', 'Disney+']
        for col in plataformas:
            if col in df.columns:
                df[col] = df[col].map({1: 'SIM', 0: 'NAO'}).fillna(df[col])

        cols_to_drop = ['IMDb', 'Rotten Tomatoes', 'Type', 'Unnamed: 0']
        cols_existentes = [col for col in cols_to_drop if col in df.columns]
        df = df.drop(columns=cols_existentes)

        # 3. Salvar
        csv_buffer = StringIO()
        df.to_csv(csv_buffer, index=False, encoding='utf-8-sig')
        
        s3.put_object(
            Bucket=BUCKET_TRUSTED,
            Key=key,
            Body=csv_buffer.getvalue(),
            ContentType='text/csv'
        )

        return {"statusCode": 200, "linhas_processadas": len(df), "arquivo": key}

    except Exception as e:
        return {"statusCode": 500, "error": str(e)}