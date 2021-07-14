<script>
  const colors = ['gray', 'red', 'orange', 'green', 'blue', 'violet']
  const tones = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
</script>

<h2>Color palette</h2>

{#each colors as color}
  <div class="colors">
    <div class="color">
      {#each tones as tone}
        <span class="tone" {color} {tone} />
      {/each}
    </div>
  </div>
{/each}

<style lang="scss">
  .colors {
    @include bgcolor(main);
  }

  .color {
    @include grid(1fr, $gap: 0.5rem);
    grid-template-columns: repeat(5, 1fr);

    margin-top: 1rem;
  }

  $colors: (gray, red, orange, yellow, green, blue, violet);

  .tone {
    height: 2rem;
    background-color: #aaa;
    display: inline-block;

    @include bdradi();
    @include shadow();

    @each $name in $colors {
      @for $tone from 0 through 9 {
        &:global([color='#{"" + $name}']):global([tone='#{"" + $tone}']) {
          @include bgcolor($name, $tone);
        }
      }
    }
  }
</style>
