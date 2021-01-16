<script context="module">
  function map_status(status) {
    switch (status) {
      case 0:
        return 'Còn tiếp'
      case 1:
        return 'Hoàn thành'
      case 2:
        return 'Thái giám'
      default:
        return 'Không rõ'
    }
  }

  import { self_power } from '$src/stores'
  import { mark_types, mark_names, mark_icons } from '$utils/constants'

  import SvgIcon from '$atoms/SvgIcon'
  import BookCover from '$atoms/BookCover'
  import RelTime from '$atoms/RelTime'

  import Vessel from '$parts/Vessel'

  const firstTLDs = 'ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|be|bf|bg|bh|bi|bj|bm|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|cl|cm|cn|co|cr|cu|cv|cw|cx|cz|de|dj|dk|dm|do|dz|ec|ee|eg|es|et|eu|fi|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|im|in|io|iq|ir|is|it|je|jo|jp|kg|ki|km|kn|kp|kr|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|na|nc|ne|nf|ng|nl|no|nr|nu|nz|om|pa|pe|pf|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|yt'.split(
    '|'
  )
  const secondTLDs = 'com|edu|gov|net|mil|org|nom|sch|caa|res|off|gob|int|tur|ip6|uri|urn|asn|act|nsw|qld|tas|vic|pro|biz|adm|adv|agr|arq|art|ato|bio|bmd|cim|cng|cnt|ecn|eco|emp|eng|esp|etc|eti|far|fnd|fot|fst|g12|ggf|imb|ind|inf|jor|jus|leg|lel|mat|med|mus|not|ntr|odo|ppg|psc|psi|qsl|rec|slg|srv|teo|tmp|trd|vet|zlg|web|ltd|sld|pol|fin|k12|lib|pri|aip|fie|eun|sci|prd|cci|pvt|mod|idv|rel|sex|gen|nic|abr|bas|cal|cam|emr|fvg|laz|lig|lom|mar|mol|pmn|pug|sar|sic|taa|tos|umb|vao|vda|ven|mie|北海道|和歌山|神奈川|鹿児島|ass|rep|tra|per|ngo|soc|grp|plc|its|air|and|bus|can|ddr|jfk|mad|nrw|nyc|ski|spy|tcm|ulm|usa|war|fhs|vgs|dep|eid|fet|fla|flå|gol|hof|hol|sel|vik|cri|iwi|ing|abo|fam|gok|gon|gop|gos|aid|atm|gsm|sos|elk|waw|est|aca|bar|cpa|jur|law|sec|plo|www|bir|cbg|jar|khv|msk|nov|nsk|ptz|rnd|spb|stv|tom|tsk|udm|vrn|cmw|kms|nkz|snz|pub|fhv|red|ens|nat|rns|rnu|bbs|tel|bel|kep|nhs|dni|fed|isa|nsn|gub|e12|tec|орг|обр|упр|alt|nis|jpn|mex|ath|iki|nid|gda|inc'.split(
    '|'
  )

  function host_name(origin_url) {
    const uri = new URL(origin_url)
    const host = uri.hostname.split('.')

    if (firstTLDs.includes(host[host.length - 1])) host.pop()
    if (secondTLDs.includes(host[host.length - 1])) host.pop()

    return host.pop()
  }
</script>

<script>
  export let bslug
  export let bhash

  export let btitle = []
  export let author = []
  export let genres = []

  export let status
  export let bcover = 'blank.png'
  export let bintro = []
  export let update_tz = 0

  export let rating
  export let voters

  export let bmark = ''
  export let atab = 'summary'

  export let origin = null
  export let yousuu = null

  $: zh_title = btitle[0]
  $: vi_title = btitle[2] || btitle[1]

  $: vi_author = author[1] || author[0]

  $: vi_status = map_status(status)

  $: book_url = `https://chivi.xyz/~${bslug}`
  $: book_intro = bintro.join('').substring(0, 300)
  $: book_cover = `https://chivi.xyz/covers/${bcover}`
  $: updated_at = new Date(update_tz)
  $: keywords = gen_keywords()

  async function mark_book(new_mark) {
    if (mark == new_mark) mark = ''
    else mark = new_mark

    const url = `/api/book-marks/${bhash}?bmark=${mark}`
    await fetch(url, { method: 'PUT' })
  }

  function gen_keywords() {
    let res = [...btitle, ...author, ...genres]
    res.push('Truyện tàu', 'Truyện convert', 'Truyện mạng')
    return res.join(',')
  }
</script>

<svelte:head>
  <title>{vi_title} - Chivi</title>
  <meta name="keywords" content={keywords} />
  <meta name="description" content={book_intro} />

  <meta property="og:title" content={vi_title} />
  <meta property="og:type" content="novel" />
  <meta property="og:description" content={book_intro} />
  <meta property="og:url" content={book_url} />
  <meta property="og:image" content={book_cover} />

  <meta property="og:novel:category" content={genres[0]} />
  <meta property="og:novel:author" content={vi_author} />
  <meta property="og:novel:book_name" content={vi_title} />
  <meta property="og:novel:read_url" content="{book_url}&tab=content" />
  <meta property="og:novel:status" content={vi_status} />
  <meta property="og:novel:update_time" content={updated_at.toISOString()} />
</svelte:head>

<Vessel>
  <a slot="header-left" href="/~{bslug}" class="header-item _active">
    <SvgIcon name="book-open" />
    <span class="header-text _title">{vi_title}</span>
  </a>

  <span slot="header-right" class="header-item _menu">
    <SvgIcon name={bmark ? mark_icons[bmark] : 'bookmark'} />
    <span class="header-text _show-md"
      >{bmark ? mark_names[bmark] : 'Đánh dấu'}</span>

    {#if $self_power > 0}
      <div class="header-menu">
        {#each mark_types as mtype}
          <div class="-item" on:click={() => mark_book(mtype)}>
            <SvgIcon name={mark_icons[mtype]} />
            <span>{mark_names[mtype]}</span>

            {#if bmark == mtype}
              <span class="_right">
                <SvgIcon name="check" />
              </span>
            {/if}
          </div>
        {/each}
      </div>
    {/if}
  </span>

  <div class="main-info">
    <div class="title">
      <h1 class="-main">{vi_title}</h1>
      <h2 class="-sub">({zh_title})</h2>
    </div>

    <div class="cover">
      <BookCover {bhash} cover={bcover} />
    </div>

    <section class="extra">
      <div class="line">
        <span class="stat">
          <SvgIcon name="pen-tool" />
          <a class="link" href="/search?kw={vi_author}&type=author">
            <span class="label">{vi_author}</span>
          </a>
        </span>

        {#each genres as genre}
          <span class="stat _genre">
            <SvgIcon name="folder" />
            <a class="link" href="/?genre={genre}">
              <span class="label">{genre}</span>
            </a>
          </span>
        {/each}
      </div>

      <div class="line">
        <span class="stat _status">
          <SvgIcon name="activity" />
          <span>{vi_status}</span>
        </span>

        <span class="stat _mftime">
          <SvgIcon name="clock" />
          <span><RelTime time={update_tz} /></span>
        </span>
      </div>

      <div class="line">
        <span class="stat">
          Đánh giá:
          <span class="label">{voters <= 10 ? '--' : rating / 10}</span>/10
        </span>
        <span class="stat">({voters} lượt đánh giá)</span>
      </div>

      {#if yousuu || origin}
        <div class="line">
          <span class="stat">Liên kết:</span>

          {#if origin != ''}
            <a
              class="stat link _outer"
              href={origin}
              rel="noopener noreferer"
              target="_blank"
              title="Trang nguồn">
              {host_name(origin)}
            </a>
          {/if}

          {#if yousuu !== ''}
            <a
              class="stat link _outer"
              href="https://www.yousuu.com/book/{yousuu}"
              rel="noopener noreferer"
              target="_blank"
              title="Đánh giá"> yousuu </a>
          {/if}
        </div>
      {/if}
    </section>
  </div>

  <div class="section">
    <header class="section-header">
      <a href="/~{bslug}" class="header-tab" class:_active={atab == 'summary'}>
        Tổng quan
      </a>

      <a
        href="/~{bslug}/content"
        class="header-tab"
        class:_active={atab == 'content'}> Chương tiết </a>

      <a
        href="/~{bslug}/discuss"
        class="header-tab"
        class:_active={atab == 'discuss'}> Thảo luận </a>
    </header>

    <div class="section-content">
      <slot />
    </div>
  </div>
</Vessel>

<style lang="scss">
  .main-info {
    padding-top: 0.75rem;
    @include flow();
  }

  .title {
    margin-bottom: 0.75rem;

    @include props(float, left, left, right);
    @include props(width, 100%, 100%, 70%, 75%);
    @include props(padding-left, 0, 0, 0.75rem);

    > .-main,
    > .-sub {
      @include fgcolor(neutral, 8);
      display: inline-block;
      font-weight: 400;
      @include props(line-height, 1.5rem, 1.75rem, 2rem);
    }

    > .-main {
      @include props(font-size, rem(20px), rem(22px), rem(22px), rem(24px));
    }

    > .-sub {
      @include props(font-size, rem(18px), rem(20px), rem(20px), rem(22px));
    }
  }

  .cover {
    float: left;
    @include props(width, 40%, 35%, 30%, 25%);
  }

  .extra {
    float: right;
    padding-left: 0.75rem;

    @include props(width, 60%, 65%, 70%, 75%);

    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  .line {
    margin-bottom: 0.5rem;
    @include fgcolor(neutral, 6);
    @include flex($wrap: true);
    @include flex-gap($gap: 0, $child: ':global(*)');
  }

  .stat {
    margin-right: 0.5rem;
  }

  .link {
    // font-weight: 500;
    color: inherit;
    // @include fgcolor(primary, 7);

    &._outer {
      text-transform: capitalize;
    }

    &._outer,
    &:hover {
      @include fgcolor(primary, 6);
    }
  }

  .label {
    font-weight: 500;
    // @include fgcolor(neutral, 8);
  }

  .section {
    background-color: #fff;

    margin: 0 -0.5rem;
    padding: 0 0.5rem;

    border-radius: 0.5rem;

    @include shadow(2);

    @include screen-min(md) {
      margin: 0.75rem 0;
      padding-left: 1rem;
      padding-right: 1rem;
      border-radius: 1rem;
    }
  }

  $section-height: 3rem;
  .section-header {
    height: $section-height;
    display: flex;
    @include border($sides: bottom, $color: neutral, $shade: 3);
  }

  .header-tab {
    height: $section-height;
    line-height: $section-height;
    width: 50%;
    font-weight: 500;
    text-align: center;
    text-transform: uppercase;

    @include font-size(2);
    @include screen-min(md) {
      @include font-size(3);
    }

    @include fgcolor(neutral, 6);
    &._active {
      @include fgcolor(primary, 6);
      @include border($sides: bottom, $color: primary, $shade: 5, $width: 2px);
    }
  }

  .section-content {
    padding: 0.75rem 0;
    display: block;
    min-height: 50vh;
  }
</style>
